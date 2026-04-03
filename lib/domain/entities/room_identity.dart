import 'package:equatable/equatable.dart';

class RoomIdentity extends Equatable {
  const RoomIdentity({
    required this.roomCode,
    required this.anonymousUid,
    required this.displayName,
  });

  final String roomCode;
  final String anonymousUid;
  final String displayName;

  @override
  List<Object?> get props => [roomCode, anonymousUid, displayName];
}
