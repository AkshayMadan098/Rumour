import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchRecentMessages(
    String roomCode, {
    int limit,
  });

  Future<List<ChatMessage>> fetchOlderThan(
    String roomCode,
    DateTime oldestTime,
    int limit,
  );

  Future<void> sendMessage({
    required String roomCode,
    required String authorUid,
    required String authorName,
    required String text,
  });
}
