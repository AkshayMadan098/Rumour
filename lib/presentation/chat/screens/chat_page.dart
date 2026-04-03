import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/room_identity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/date_separator.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.roomCode,
    required this.identity,
  });

  final String roomCode;
  final RoomIdentity identity;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  DateTime? _lastLoadMoreAt;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels > 140) return;
    final now = DateTime.now();
    if (_lastLoadMoreAt != null &&
        now.difference(_lastLoadMoreAt!) < const Duration(milliseconds: 700)) {
      return;
    }
    _lastLoadMoreAt = now;
    context.read<ChatCubit>().loadMore();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat.yMMMd().format(d);
  }

  static List<_ChatItem> _itemsFor(List<ChatMessage> messages) {
    if (messages.isEmpty) return [];
    DateTime? lastDay;
    final out = <_ChatItem>[];
    for (final m in messages) {
      final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
      if (lastDay == null ||
          day.year != lastDay.year ||
          day.month != lastDay.month ||
          day.day != lastDay.day) {
        out.add(_ChatItemDate(_dayLabel(day)));
        lastDay = day;
      }
      out.add(_ChatItemMessage(m));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (p, c) {
        if (c.messages.isEmpty) return false;
        if (p.messages.isEmpty) return true;
        return c.messages.last.id != p.messages.last.id;
      },
      listener: (context, state) {
        if (state.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scroll.hasClients) {
              _scroll.animateTo(
                _scroll.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            }
          });
        }
        if (state.sendError != null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.sendError!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent,
            ),
          );
          context.read<ChatCubit>().clearSendError();
        }
      },
      builder: (context, state) {
        final items = _itemsFor(state.messages);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark ? AppColors.black : AppColors.lightScaffold;

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              children: [
                _ChatAppBar(
                  roomCode: widget.roomCode,
                  memberCount: state.memberCount,
                  isDark: isDark,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final it = items[i];
                      if (it is _ChatItemDate) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: DateSeparator(label: it.label),
                        );
                      }
                      if (it is _ChatItemMessage) {
                        final message = it.message;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: MessageBubble(
                            message: message,
                            isOutgoing: message.isFrom(widget.identity.anonymousUid),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                _MessageComposer(
                  controller: _input,
                  isDark: isDark,
                  scaffoldBg: bg,
                  onSend: () {
                    final t = _input.text.trim();
                    if (t.isEmpty) return;
                    _input.clear();
                    context.read<ChatCubit>().send(t);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

sealed class _ChatItem {
  const _ChatItem();
}

final class _ChatItemDate extends _ChatItem {
  const _ChatItemDate(this.label);
  final String label;
}

final class _ChatItemMessage extends _ChatItem {
  const _ChatItemMessage(this.message);
  final ChatMessage message;
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({
    required this.roomCode,
    required this.memberCount,
    required this.isDark,
    required this.onBack,
  });

  final String roomCode;
  final int memberCount;
  final bool isDark;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? AppColors.white : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.secondaryText : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _RoundButton(
            icon: Icons.chevron_left_rounded,
            isDark: isDark,
            onTap: onBack,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Room #$roomCode',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$memberCount members',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? AppColors.white : AppColors.lightTextPrimary;
    return Material(
      color: isDark ? AppColors.iconCircle : AppColors.lightIncoming,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: iconColor,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.isDark,
    required this.scaffoldBg,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isDark;
  final Color scaffoldBg;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final fieldBg = isDark ? const Color(0xFF0D1117) : AppColors.lightIncoming;
    final textColor = isDark ? AppColors.white : AppColors.lightTextPrimary;
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: scaffoldBg,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(color: hintColor),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.lime,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.black),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
