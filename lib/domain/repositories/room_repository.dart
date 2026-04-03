import '../entities/room_identity.dart';

abstract class RoomRepository {
  Future<RoomIdentity?> getStoredIdentity(String roomCode);

  Future<RoomIdentity> createIdentityForRoom(String roomCode);

  Future<void> persistIdentity(RoomIdentity identity);

  /// Ensures the room document exists (create or join).
  Future<void> ensureRoom(String roomCode);

  /// Registers member if missing; increments [memberCount] when new.
  Future<void> registerMemberIfNeeded(RoomIdentity identity);

  /// Stream of member count for app bar.
  Stream<int> watchMemberCount(String roomCode);

  /// Generates a new unused 6-digit room code (best-effort).
  Future<String> createNewRoomCode();
}
