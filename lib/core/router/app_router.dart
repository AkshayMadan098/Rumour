import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/room_identity.dart';
import '../../presentation/chat/cubit/chat_cubit.dart';
import '../../presentation/chat/screens/chat_page.dart';
import '../../presentation/identity/cubit/identity_cubit.dart';
import '../../presentation/identity/screens/identity_page.dart';
import '../../presentation/join_room/cubit/join_room_cubit.dart';
import '../../presentation/join_room/screens/join_room_page.dart';
import '../di/service_locator.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
          create: (_) => JoinRoomCubit(sl()),
          child: const JoinRoomPage(),
        ),
      ),
      GoRoute(
        path: '/identity/:code',
        builder: (context, state) {
          final code = state.pathParameters['code']!;
          return BlocProvider(
            create: (_) => IdentityCubit(sl(), code),
            child: IdentityPage(roomCode: code),
          );
        },
      ),
      GoRoute(
        path: '/chat/:code',
        builder: (context, state) {
          final code = state.pathParameters['code']!;
          final identity = state.extra as RoomIdentity?;
          if (identity == null || identity.roomCode != code) {
            return const _IdentityMissingScreen();
          }
          return BlocProvider(
            create: (_) => ChatCubit(
              chat: sl(),
              rooms: sl(),
              roomCode: code,
              identity: identity,
            ),
            child: ChatPage(
              roomCode: code,
              identity: identity,
            ),
          );
        },
      ),
    ],
  );
}

class _IdentityMissingScreen extends StatelessWidget {
  const _IdentityMissingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Open a room from the home screen first.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Back home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final GoRouter appRouter = createAppRouter();
