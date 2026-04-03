import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../core/utils/identity_name_generator.dart';
import '../../domain/entities/room_identity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/firestore_room_datasource.dart';
import '../datasources/local_identity_datasource.dart';
import '../datasources/random_user_remote_datasource.dart';

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl({
    required FirestoreRoomDataSource firestoreRooms,
    required LocalIdentityDataSource identityLocal,
    required RandomUserRemoteDataSource randomUser,
  })  : _rooms = firestoreRooms,
        _local = identityLocal,
        _randomUser = randomUser;

  final FirestoreRoomDataSource _rooms;
  final LocalIdentityDataSource _local;
  final RandomUserRemoteDataSource _randomUser;
  final _uuid = const Uuid();

  @override
  Future<RoomIdentity?> getStoredIdentity(String roomCode) async {
    final json = await _local.loadIdentityJson(roomCode);
    if (json == null) return null;
    final uid = json['anonymousUid'] as String?;
    final name = json['displayName'] as String?;
    if (uid == null || name == null) return null;
    return RoomIdentity(
      roomCode: roomCode,
      anonymousUid: uid,
      displayName: name,
    );
  }

  @override
  Future<RoomIdentity> createIdentityForRoom(String roomCode) async {
    final seed = await _randomUser.fetchIdentitySeed();
    final displayName = displayNameFromSeed(seed);
    final anonymousUid = _uuid.v4();
    return RoomIdentity(
      roomCode: roomCode,
      anonymousUid: anonymousUid,
      displayName: displayName,
    );
  }

  @override
  Future<void> persistIdentity(RoomIdentity identity) async {
    await _local.saveIdentityJson(identity.roomCode, {
      'anonymousUid': identity.anonymousUid,
      'displayName': identity.displayName,
    });
  }

  @override
  Future<void> ensureRoom(String roomCode) =>
      _rooms.ensureRoomDocument(roomCode);

  @override
  Future<void> registerMemberIfNeeded(RoomIdentity identity) async {
    await _rooms.registerMember(
      roomCode: identity.roomCode,
      memberUid: identity.anonymousUid,
      displayName: identity.displayName,
    );
  }

  @override
  Stream<int> watchMemberCount(String roomCode) =>
      _rooms.watchMemberCount(roomCode);

  @override
  Future<String> createNewRoomCode() async {
    final rnd = Random();
    for (var i = 0; i < 32; i++) {
      final code = (100000 + rnd.nextInt(900000)).toString();
      final exists = await _rooms.roomExists(code);
      if (!exists) {
        await ensureRoom(code);
        return code;
      }
    }
    throw StateError('Unable to allocate a room code');
  }
}
