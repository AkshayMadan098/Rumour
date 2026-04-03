import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.roomCode,
    required this.authorUid,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String roomCode;
  final String authorUid;
  final String authorName;
  final String text;
  final DateTime createdAt;

  bool isFrom(String localAuthorUid) => authorUid == localAuthorUid;

  @override
  List<Object?> get props =>
      [id, roomCode, authorUid, authorName, text, createdAt];
}
