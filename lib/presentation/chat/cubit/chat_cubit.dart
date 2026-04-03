import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/room_identity.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository chat,
    required RoomRepository rooms,
    required this.roomCode,
    required this.identity,
  })  : _chat = chat,
        _rooms = rooms,
        super(const ChatState()) {
    _memberSub = _rooms.watchMemberCount(roomCode).listen((count) {
      if (!isClosed) emit(state.copyWith(memberCount: count));
    });
    _msgSub = _chat.watchRecentMessages(roomCode).listen((recent) {
      if (!isClosed) {
        emit(
          state.copyWith(
            recentWindow: recent,
            messages: _merge(older: state.olderMessages, recent: recent),
          ),
        );
      }
    });
  }

  final ChatRepository _chat;
  final RoomRepository _rooms;
  final String roomCode;
  final RoomIdentity identity;

  StreamSubscription<List<ChatMessage>>? _msgSub;
  StreamSubscription<int>? _memberSub;

  static List<ChatMessage> _merge({
    required List<ChatMessage> older,
    required List<ChatMessage> recent,
  }) {
    final map = <String, ChatMessage>{};
    for (final m in older) {
      map[m.id] = m;
    }
    for (final m in recent) {
      map[m.id] = m;
    }
    final list = map.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    final current = state.messages;
    if (current.isEmpty) return;
    final oldest = current.first;
    emit(state.copyWith(loadingMore: true));
    try {
      final batch = await _chat.fetchOlderThan(
        roomCode,
        oldest.createdAt,
        25,
      );
      if (batch.isEmpty) {
        emit(state.copyWith(loadingMore: false, hasMore: false));
        return;
      }
      final older = [...batch, ...state.olderMessages];
      emit(
        state.copyWith(
          loadingMore: false,
          olderMessages: older,
          messages: _merge(older: older, recent: state.recentWindow),
          hasMore: batch.length >= 25,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loadingMore: false));
    }
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    try {
      await _chat.sendMessage(
        roomCode: roomCode,
        authorUid: identity.anonymousUid,
        authorName: identity.displayName,
        text: trimmed,
      );
    } catch (e) {
      emit(state.copyWith(sendError: 'Message not sent. Try again.'));
    }
  }

  void clearSendError() {
    emit(state.copyWith(clearSendError: true));
  }

  @override
  Future<void> close() async {
    await _msgSub?.cancel();
    await _memberSub?.cancel();
    return super.close();
  }
}
