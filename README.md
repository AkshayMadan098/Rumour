# Rumour

**Rumour** is a Flutter app for **anonymous, room-based chat** backed by **Firebase Cloud Firestore**. Users join with a **6-digit room code**, get a **random display name** (e.g. “Curious Otter”), and chat in real time with **live member counts** and **message history** loaded from Firestore.

---

## Demo assets

| Asset | Link / location |
|--------|-----------------|
| **Screen recording** | [Watch on Google Drive](https://drive.google.com/file/d/1Op1IdvQqiFUn0e9BZzFNcyHivaHyeGkS/view?usp=sharing) (Screen Recording .mov) |
| **Android APK** | [Download on Google Drive](https://drive.google.com/file/d/1B6BDhu3xKS3asm9wVAcOl6x9XCJjY1Kf/view?usp=sharing) (~**52.4 MB**, `app-release.apk`). To build locally: `flutter build apk --release` → [`build/app/outputs/flutter-apk/app-release.apk`](build/app/outputs/flutter-apk/app-release.apk). |

---

## What we implemented

- **Join or create rooms** — Enter a 6-digit code or generate a new room; Firestore ensures the room document exists.
- **Per-room anonymous identity** — Display names are derived from [randomuser.me](https://randomuser.me/) seed data plus a deterministic “Adjective Animal” generator; a local UUID identifies the user in that room.
- **Identity persistence** — `SharedPreferences` stores identity per room so returning users skip re-onboarding when possible.
- **Member registration** — On first acknowledge, the app writes to `rooms/{code}/members/{uid}` and updates `memberCount` via a Firestore **transaction**.
- **Real-time chat** — Messages live under `rooms/{code}/messages` with `createdAt` ordering; the UI subscribes to snapshots for live updates.
- **Pagination** — Older messages load in batches when scrolling up (`startAfter` on `createdAt`).
- **Live member count** — Stream from the room document’s `memberCount` field.
- **Theming** — Light/dark `MaterialApp` themes via `ThemeCubit` (defaults to dark).
- **Routing** — Declarative routes with **go_router**; deep link guard if `/chat/:code` is opened without `RoomIdentity` in `extra`.
- **Offline-friendly (mobile)** — Firestore persistence enabled with unlimited cache on non-web platforms.
- **Security rules** — `firestore.rules` in the repo (open read/create for demo; comments note tightening for production).

---

## Architecture

We use a **layered, clean-style layout** so UI stays thin and data access stays testable and swappable.

```
lib/
├── presentation/     # Screens + Flutter Bloc Cubits + widgets
├── domain/           # Entities + repository interfaces
├── data/             # Repository implementations + datasources
└── core/             # DI, router, theme, shared utils
```

- **Domain** — Pure models (`RoomIdentity`, `ChatMessage`) and contracts (`RoomRepository`, `ChatRepository`).
- **Data** — Implements repositories by composing:
  - **Firestore** datasources (`FirestoreRoomDataSource`, `FirestoreChatDataSource`)
  - **Local** identity storage (`LocalIdentityDataSource` → `SharedPreferences`)
  - **Remote** entropy for names (`RandomUserRemoteDataSource` → HTTP)
- **Presentation** — One feature folder per flow (`join_room`, `identity`, `chat`), each with its own **Cubit** and **state** classes.

**Dependency injection** — **get_it** (`lib/core/di/service_locator.dart`) registers singletons/lazy singletons for Firestore, HTTP client, datasources, and repositories after `SharedPreferences` is ready in `main.dart`.

### Why clean architecture?

- **Separation of concerns** — UI only renders and forwards user intent; business rules and orchestration live in repositories and cubits, so screens do not become a mix of widgets, Firestore calls, and HTTP.
- **Testability** — Domain types and repository contracts can be unit-tested and faked without Firebase or `BuildContext`. You can swap a mock `ChatRepository` in tests while keeping cubit logic unchanged.
- **Stable boundaries** — Firestore field names, transactions, and HTTP APIs stay inside **data** datasources. If the backend or a third-party API changes, you update one layer instead of hunting through every screen.
- **Scales with the app** — New features (`presentation/<feature>` + cubit + optional new repository methods) follow the same pattern, which keeps onboarding and code review predictable.

---

## State management

- **flutter_bloc** — Feature state is handled with **Cubit** (not full Bloc events), keeping logic explicit and easy to follow:
  - `JoinRoomCubit` — room code input, join/create, outcomes (open chat vs. need identity).
  - `IdentityCubit` — load/create identity, persist, register member in Firestore.
  - `ChatCubit` — subscribes to message and member-count streams, merge/pagination, send messages.
- **ThemeCubit** — App-wide `ThemeMode` at the root `BlocProvider` in `main.dart`.
- **Equatable** — State and entity classes use `Equatable` for value equality where defined.

Cubits receive **repository interfaces** from get_it; they do not talk to Firestore or HTTP directly.

### Why Cubit?

- **Clear, imperative flow** — Most features here are “call a method, emit a new state” (join room, acknowledge identity, send message). **Cubit** exposes named methods (`joinRoom`, `send`, `loadMore`) instead of routing every action through event classes, which keeps the codebase smaller and easier to read for these flows.
- **Same benefits as Bloc** — Predictable state transitions, `BlocBuilder` / `BlocListener` integration, easy to test by driving the cubit and asserting emitted states—without the extra ceremony of defining event types where events would be thin wrappers around those same calls.
- **Works well with streams** — `ChatCubit` listens to Firestore-backed repository streams and merges pagination; cubits are a natural place to hold `StreamSubscription`s and cancel them in `close()`, matching how this app combines one-shot actions with live updates.
- **Feature-scoped providers** — Each route provides its own cubit (`JoinRoomCubit`, `IdentityCubit`, `ChatCubit`), so state is tied to the screen lifecycle and does not leak across the whole app.

We still use **Bloc** at the package level (`flutter_bloc`) because Cubit is part of that ecosystem; we simply chose Cubit over full **Bloc<Event, State>** where events would not add meaningful structure.

---

## Firestore data model

- **`rooms/{roomCode}`** — Room metadata: `createdAt`, `memberCount`.
- **`rooms/{roomCode}/members/{memberUid}`** — `displayName`, `joinedAt` (created on first acknowledge; count incremented in a transaction).
- **`rooms/{roomCode}/messages/{messageId}`** — `authorUid`, `authorName`, `text`, `createdAt` (server timestamp).

Rules are in [`firestore.rules`](firestore.rules). Deploy them in the Firebase Console or with the Firebase CLI so clients can read/write as intended.

---

## Tech stack

| Area | Choice |
|------|--------|
| Framework | Flutter (SDK ^3.11.1) |
| Backend | Firebase Core + **Cloud Firestore** |
| State | **flutter_bloc** (Cubit) + **equatable** |
| DI | **get_it** |
| Navigation | **go_router** |
| Local storage | **shared_preferences** (identities) |
| HTTP | **http** (randomuser.me) |
| IDs | **uuid** |
| UI | **google_fonts**, Material 3 themes |

---

## Running the app

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and run `flutter pub get`.
2. Add your Firebase project: place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) as usual; `lib/firebase_options.dart` should match your Firebase app.
3. Deploy **`firestore.rules`** to your Firestore database.
4. `flutter run` (or build for release).

---

## Tests

The project includes widget tests and unit tests (e.g. identity name generation). Run:

```bash
flutter test
```
