import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/room_repository.dart';
import 'join_room_state.dart';

class JoinRoomCubit extends Cubit<JoinRoomState> {
  JoinRoomCubit(this._rooms) : super(const JoinRoomState());

  final RoomRepository _rooms;

  void setDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 6) return;
    if (state.submitting) return;
    emit(state.copyWith(digits: digits, errorMessage: null));
    if (digits.length == 6) {
      joinRoom();
    }
  }

  Future<void> joinRoom() async {
    if (state.digits.length != 6) {
      emit(state.copyWith(errorMessage: 'Enter the 6-digit room code.'));
      return;
    }
    if (state.submitting) return;
    emit(state.copyWith(submitting: true, errorMessage: null));
    try {
      final code = state.digits;
      await _rooms.ensureRoom(code);
      final existing = await _rooms.getStoredIdentity(code);
      if (existing != null) {
        emit(state.copyWith(
          submitting: false,
          outcome: JoinOutcomeOpenChat(existing),
        ));
      } else {
        emit(state.copyWith(
          submitting: false,
          outcome: JoinOutcomeNeedsIdentity(code),
        ));
      }
    } catch (e, st) {
      debugPrint('joinRoom failed: $e\n$st');
      emit(state.copyWith(
        submitting: false,
        errorMessage: _firestoreUserMessage(e,
            fallback: 'Could not join the room. Check your connection.'),
      ));
    }
  }

  Future<void> createRoom() async {
    emit(state.copyWith(submitting: true, errorMessage: null));
    try {
      final code = await _rooms.createNewRoomCode();
      emit(state.copyWith(
        digits: code,
        submitting: false,
        outcome: JoinOutcomeNeedsIdentity(code),
      ));
    } catch (e, st) {
      debugPrint('createRoom failed: $e\n$st');
      emit(state.copyWith(
        submitting: false,
        errorMessage: _firestoreUserMessage(e,
            fallback: 'Could not create a room. Try again.'),
      ));
    }
  }

  void clearOutcome() {
    emit(state.copyWith(clearOutcome: true));
  }
}

String _firestoreUserMessage(Object e, {required String fallback}) {
  if (e is StateError) {
    return e.message;
  }
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        return 'Firestore denied access. Open Firebase Console → Firestore → '
            'Rules and allow reads/writes for rooms (or deploy firestore.rules '
            'from this project).';
      case 'unavailable':
        return 'Firestore is unavailable. Check your network and try again.';
      case 'failed-precondition':
        return 'Firestore setup issue: ${e.message ?? e.code}';
      default:
        if (kDebugMode && e.message != null && e.message!.isNotEmpty) {
          return '${e.code}: ${e.message}';
        }
        return fallback;
    }
  }
  return fallback;
}
