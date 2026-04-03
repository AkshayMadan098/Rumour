import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_message.dart';

class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.recentWindow = const [],
    this.olderMessages = const [],
    this.loadingMore = false,
    this.hasMore = true,
    this.memberCount = 0,
    this.sendError,
  });

  final List<ChatMessage> messages;
  final List<ChatMessage> recentWindow;
  final List<ChatMessage> olderMessages;
  final bool loadingMore;
  final bool hasMore;
  final int memberCount;
  final String? sendError;

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatMessage>? recentWindow,
    List<ChatMessage>? olderMessages,
    bool? loadingMore,
    bool? hasMore,
    int? memberCount,
    String? sendError,
    bool clearSendError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      recentWindow: recentWindow ?? this.recentWindow,
      olderMessages: olderMessages ?? this.olderMessages,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      memberCount: memberCount ?? this.memberCount,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
    );
  }

  @override
  List<Object?> get props => [
        messages,
        recentWindow,
        olderMessages,
        loadingMore,
        hasMore,
        memberCount,
        sendError,
      ];
}
