import 'package:equatable/equatable.dart';

import '../../../domain/entities/room_identity.dart';

class IdentityState extends Equatable {
  const IdentityState({
    this.loading = true,
    this.ackInFlight = false,
    this.identity,
    this.errorMessage,
    this.done = false,
  });

  final bool loading;
  final bool ackInFlight;
  final RoomIdentity? identity;
  final String? errorMessage;
  final bool done;

  IdentityState copyWith({
    bool? loading,
    bool? ackInFlight,
    RoomIdentity? identity,
    String? errorMessage,
    bool? done,
    bool clearError = false,
  }) {
    return IdentityState(
      loading: loading ?? this.loading,
      ackInFlight: ackInFlight ?? this.ackInFlight,
      identity: identity ?? this.identity,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props =>
      [loading, ackInFlight, identity, errorMessage, done];
}
