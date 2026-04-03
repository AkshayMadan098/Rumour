import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/room_repository.dart';
import 'identity_state.dart';

class IdentityCubit extends Cubit<IdentityState> {
  IdentityCubit(this._rooms, this.roomCode)
      : super(const IdentityState()) {
    _load();
  }

  final RoomRepository _rooms;
  final String roomCode;

  Future<void> _load() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      await _rooms.ensureRoom(roomCode);
      final cached = await _rooms.getStoredIdentity(roomCode);
      if (cached != null) {
        emit(state.copyWith(loading: false, identity: cached));
        return;
      }
      final fresh = await _rooms.createIdentityForRoom(roomCode);
      emit(state.copyWith(loading: false, identity: fresh));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        errorMessage: 'Could not assign an identity. Try again.',
      ));
    }
  }

  Future<void> retry() => _load();

  Future<void> acknowledge() async {
    final id = state.identity;
    if (id == null) return;
    emit(state.copyWith(ackInFlight: true, errorMessage: null));
    try {
      await _rooms.persistIdentity(id);
      await _rooms.registerMemberIfNeeded(id);
      emit(state.copyWith(ackInFlight: false, done: true));
    } catch (e, st) {
      debugPrint('acknowledge failed: $e\n$st');
      emit(state.copyWith(
        ackInFlight: false,
        errorMessage: _ackErrorMessage(e),
      ));
    }
  }
}

String _ackErrorMessage(Object e) {
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        return 'Firestore denied saving your profile. Check Firestore rules '
            'for rooms/{id}/members.';
      case 'unavailable':
        return 'Network issue. Check connection and tap again.';
      default:
        if (kDebugMode && e.message != null && e.message!.isNotEmpty) {
          return '${e.code}: ${e.message}';
        }
    }
  }
  return 'Something went wrong. Please retry.';
}
