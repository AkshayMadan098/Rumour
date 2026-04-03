import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/room_identity.dart';
import '../cubit/identity_cubit.dart';
import '../cubit/identity_state.dart';

class IdentityPage extends StatelessWidget {
  const IdentityPage({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).colorScheme.surface;

    return BlocListener<IdentityCubit, IdentityState>(
      listenWhen: (p, c) => !p.done && c.done,
      listener: (context, state) {
        final id = state.identity;
        if (id != null) {
          context.go('/chat/${id.roomCode}', extra: id);
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              _IdentityAppBar(roomCode: roomCode),
              Expanded(
                child: BlocBuilder<IdentityCubit, IdentityState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      );
                    }
                    if (state.errorMessage != null && state.identity == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: () =>
                                    context.read<IdentityCubit>().retry(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final id = state.identity;
                    if (id == null) {
                      return const SizedBox.shrink();
                    }
                    return _IdentityBody(
                      identity: id,
                      isDark: isDark,
                      busy: state.ackInFlight,
                      error: state.errorMessage,
                      onAck: () =>
                          context.read<IdentityCubit>().acknowledge(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityAppBar extends StatelessWidget {
  const _IdentityAppBar({required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.chevron_left_rounded,
            isDark: isDark,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Room #$roomCode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: isDark
                            ? AppColors.white
                            : AppColors.lightTextPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'New member',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.secondaryText
                            : AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.isDark,
    required this.onPressed,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.iconCircle : AppColors.lightIncoming,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: isDark ? AppColors.white : AppColors.lightTextPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _IdentityBody extends StatelessWidget {
  const _IdentityBody({
    required this.identity,
    required this.isDark,
    required this.busy,
    required this.onAck,
    this.error,
  });

  final RoomIdentity identity;
  final bool isDark;
  final bool busy;
  final VoidCallback onAck;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardNavy : AppColors.lightSurface;
    final hint = isDark ? AppColors.secondaryTextAlt : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 480),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) {
                  return Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: 0.96 + 0.04 * t,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 36, 22, 36),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'For this room, you are',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: hint,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        identity.displayName,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 34,
                                  height: 1.05,
                                  color: AppColors.lime,
                                  letterSpacing: -0.8,
                                ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'This is your anonymous identifier, visible only to '
                        'others in this room.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: hint,
                              height: 1.45,
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (error != null) ...[
            Text(
              error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lime.withValues(alpha: isDark ? 0.42 : 0.28),
                  blurRadius: 26,
                  spreadRadius: -2,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: busy ? null : onAck,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: AppColors.outgoingText,
                  disabledBackgroundColor:
                      AppColors.lime.withValues(alpha: 0.55),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: busy
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color:
                              AppColors.outgoingText.withValues(alpha: 0.85),
                        ),
                      )
                    : Text(
                        'Acknowledge and continue',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.outgoingText,
                                ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
