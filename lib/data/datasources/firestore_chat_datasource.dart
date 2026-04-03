import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message.dart';

abstract class FirestoreChatDataSource {
  Stream<List<ChatMessage>> watchRecent(String roomCode, {int limit});

  Future<List<ChatMessage>> fetchOlderThan(
    String roomCode,
    DateTime oldestInclusive,
    int limit,
  );

  Future<void> send({
    required String roomCode,
    required String authorUid,
    required String authorName,
    required String text,
  });
}

class FirestoreChatDataSourceImpl implements FirestoreChatDataSource {
  FirestoreChatDataSourceImpl(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _messages(String roomCode) =>
      _db.collection('rooms').doc(roomCode).collection('messages');

  ChatMessage _mapDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['createdAt'];
    DateTime at;
    if (ts is Timestamp) {
      at = ts.toDate();
    } else {
      at = DateTime.fromMillisecondsSinceEpoch(0);
    }
    return ChatMessage(
      id: doc.id,
      roomCode: doc.reference.parent.parent!.id,
      authorUid: data['authorUid'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown',
      text: data['text'] as String? ?? '',
      createdAt: at,
    );
  }

  @override
  Stream<List<ChatMessage>> watchRecent(String roomCode, {int limit = 40}) {
    return _messages(roomCode)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) => s.docs.map(_mapDoc).toList().reversed.toList(growable: false),
        );
  }

  @override
  Future<List<ChatMessage>> fetchOlderThan(
    String roomCode,
    DateTime oldestInclusive,
    int limit,
  ) async {
    final snap = await _messages(roomCode)
        .orderBy('createdAt', descending: true)
        .startAfter([Timestamp.fromDate(oldestInclusive)])
        .limit(limit)
        .get();
    return snap.docs.map(_mapDoc).toList().reversed.toList(growable: false);
  }

  @override
  Future<void> send({
    required String roomCode,
    required String authorUid,
    required String authorName,
    required String text,
  }) async {
    await _messages(roomCode).add({
      'authorUid': authorUid,
      'authorName': authorName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
