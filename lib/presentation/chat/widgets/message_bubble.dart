import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isOutgoing,
  });

  final ChatMessage message;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleBg = isOutgoing
        ? AppColors.lime
        : (isDark ? AppColors.incomingBubble : AppColors.lightIncoming);
    final textColor = isOutgoing
        ? AppColors.outgoingText
        : (isDark ? AppColors.white : AppColors.lightTextPrimary);
    final timeColor = isOutgoing
        ? AppColors.timestampOutgoing
        : (isDark ? AppColors.timestampIncoming : AppColors.lightTextSecondary);

    return Column(
      crossAxisAlignment:
          isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            isOutgoing ? 'You' : '@${message.authorName}',
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.lightTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: BoxDecoration(
            color: bubbleBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: timeColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
