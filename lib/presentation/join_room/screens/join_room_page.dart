import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_cubit.dart';
import '../cubit/join_room_cubit.dart';
import '../cubit/join_room_state.dart';
import '../widgets/room_code_field.dart';

class JoinRoomPage extends StatelessWidget {
  const JoinRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.black : AppColors.lightScaffold;

    return BlocListener<JoinRoomCubit, JoinRoomState>(
      listenWhen: (p, c) => p.outcome != c.outcome && c.outcome != null,
      listener: (context, state) {
        final o = state.outcome;
        if (o == null) return;
        final cubit = context.read<JoinRoomCubit>();

        if (o is JoinOutcomeOpenChat) {
          context.go('/chat/${o.identity.roomCode}', extra: o.identity);
        } else if (o is JoinOutcomeNeedsIdentity) {
          context.push('/identity/${o.roomCode}');
        }

        cubit.clearOutcome();
      },
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            SafeArea(
              child: BlocBuilder<JoinRoomCubit, JoinRoomState>(
                builder: (context, state) {
                  return AbsorbPointer(
                    absorbing: state.submitting,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 48),

                          /// 🔑 Top Icon
                          Align(
                            alignment: Alignment.topCenter,
                            child: _TopIcon(isDark: isDark),
                          ),

                          /// Push content to center
                          const Spacer(),

                          /// 📝 Center Content (Text)
                          _CenterContent(isDark: isDark),

                          const SizedBox(height: 32),

                          /// 🔢 Room Code Input
                          RoomCodeField(
                            digits: state.digits,
                            enabled: !state.submitting,
                            onChanged: context
                                .read<JoinRoomCubit>()
                                .setDigits,
                          ),

                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error,
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          /// ➕ Create Room
                          TextButton(
                            onPressed: state.submitting
                                ? null
                                : () => context
                                .read<JoinRoomCubit>()
                                .createRoom(),
                            child: Text(
                              'Create a new room',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                color: isDark
                                    ? AppColors.secondaryText
                                    : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// 🌙 Theme Toggle
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: 16,
              child: IconButton(
                tooltip: 'Toggle theme',
                onPressed: () =>
                    context.read<ThemeCubit>().toggle(),
                icon: Icon(
                  isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: isDark
                      ? AppColors.secondaryText
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔑 Top Icon Widget
class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.iconCircle : AppColors.lightIncoming,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.vpn_key_rounded,
        size: 40,
        color: AppColors.joinLime,
      ),
    );
  }
}

/// 📝 Center Content Widget
class _CenterContent extends StatelessWidget {
  const _CenterContent({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 12),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Text(
            'Join A Room',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 32,
              letterSpacing: -0.5,
              color: isDark
                  ? AppColors.white
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Enter the code to join the anon chat room',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.35,
                color: isDark
                    ? AppColors.secondaryText
                    : AppColors.lightTextSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🚀 Primary Button
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.joinLime,
          foregroundColor: AppColors.outgoingText,
          disabledBackgroundColor:
          AppColors.joinLime.withValues(alpha: 0.5),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: loading
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
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.outgoingText,
          ),
        ),
      ),
    );
  }
}