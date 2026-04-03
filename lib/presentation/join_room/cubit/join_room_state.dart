import 'package:equatable/equatable.dart';

import '../../../domain/entities/room_identity.dart';

sealed class JoinOutcome {
  const JoinOutcome();
}

final class JoinOutcomeNeedsIdentity extends JoinOutcome {
  const JoinOutcomeNeedsIdentity(this.roomCode);
  final String roomCode;
}

final class JoinOutcomeOpenChat extends JoinOutcome {
  const JoinOutcomeOpenChat(this.identity);
  final RoomIdentity identity;
}

class JoinRoomState extends Equatable {
  const JoinRoomState({
    this.digits = '',
    this.submitting = false,
    this.errorMessage,
    this.outcome,
  });

  final String digits;
  final bool submitting;
  final String? errorMessage;
  final JoinOutcome? outcome;

  JoinRoomState copyWith({
    String? digits,
    bool? submitting,
    String? errorMessage,
    JoinOutcome? outcome,
    bool clearOutcome = false,
    bool clearError = false,
  }) {
    return JoinRoomState(
      digits: digits ?? this.digits,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
    );
  }

  @override
  List<Object?> get props =>
      [digits, submitting, errorMessage, outcome];
}

