import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreRoomDataSource {
  Future<void> ensureRoomDocument(String roomCode);

  Future<void> registerMember({
    required String roomCode,
    required String memberUid,
    required String displayName,
  });

  Stream<int> watchMemberCount(String roomCode);

  Future<bool> roomExists(String roomCode);
}

class FirestoreRoomDataSourceImpl implements FirestoreRoomDataSource {
  FirestoreRoomDataSourceImpl(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _room(String code) =>
      _db.collection('rooms').doc(code);

  @override
  Future<void> ensureRoomDocument(String roomCode) async {
    final ref = _room(roomCode);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'createdAt': FieldValue.serverTimestamp(),
      'memberCount': 0,
    });
  }

  @override
  Future<void> registerMember({
    required String roomCode,
    required String memberUid,
    required String displayName,
  }) async {
    final roomRef = _room(roomCode);
    final memberRef = roomRef.collection('members').doc(memberUid);
    // Firestore requires every read in the transaction before any write.
    await _db.runTransaction((tx) async {
      final memberSnap = await tx.get(memberRef);
      final roomSnap = await tx.get(roomRef);
      if (memberSnap.exists) return;
      tx.set(memberRef, {
        'displayName': displayName,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      if (!roomSnap.exists) {
        tx.set(roomRef, {
          'createdAt': FieldValue.serverTimestamp(),
          'memberCount': 1,
        });
      } else {
        tx.update(roomRef, {'memberCount': FieldValue.increment(1)});
      }
    });
  }

  @override
  Stream<int> watchMemberCount(String roomCode) {
    return _room(roomCode).snapshots().map((d) {
      final n = d.data()?['memberCount'];
      if (n is int) return n;
      if (n is num) return n.toInt();
      return 0;
    });
  }

  @override
  Future<bool> roomExists(String roomCode) async {
    final snap = await _room(roomCode).get();
    return snap.exists;
  }
}
