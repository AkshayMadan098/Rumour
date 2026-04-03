import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/firestore_chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final FirestoreChatDataSource _remote;

  @override
  Stream<List<ChatMessage>> watchRecentMessages(
    String roomCode, {
    int limit = 40,
  }) {
    return _remote.watchRecent(roomCode, limit: limit);
  }

  @override
  Future<List<ChatMessage>> fetchOlderThan(
    String roomCode,
    DateTime oldestTime,
    int limit,
  ) {
    return _remote.fetchOlderThan(roomCode, oldestTime, limit);
  }

  @override
  Future<void> sendMessage({
    required String roomCode,
    required String authorUid,
    required String authorName,
    required String text,
  }) {
    return _remote.send(
      roomCode: roomCode,
      authorUid: authorUid,
      authorName: authorName,
      text: text,
    );
  }
}
