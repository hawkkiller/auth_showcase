// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizzle_starter/src/feature/auth/data/auth_repository.dart';
import 'package:sizzle_starter/src/feature/auth/logic/auth_interceptor.dart';

/// AuthBloc
final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  /// Create an [AuthBloc]
  ///
  /// This specializes required [initialState] as it should be preloaded.
  AuthBloc(
    super.initialState, {
    required AuthRepository authRepository,
    required AuthStatusSource authStatusSource,
  }) : _authRepository = authRepository {
    on<AuthEvent>(
      (event, emit) => switch (event) {
        final _SignInWithEmailAndPassword e =>
          _signInWithEmailAndPassword(e, emit),
        final _SignOut e => _signOut(e, emit),
      },
    );

    // emit new state when the authentication status changes
    authStatusSource.authStatus.listen((event) {
      emit(AuthState.idle(status: event));
    });
  }

  Future<void> _signOut(
    _SignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.processing(status: state.status));

    try {
      await _authRepository.signOut();
      emit(const AuthState.idle(status: AuthenticationStatus.unauthenticated));
    } on Object catch (e, stackTrace) {
      emit(
        AuthState.error(
          status: AuthenticationStatus.unauthenticated,
          message: e.toString(),
        ),
      );
      onError(e, stackTrace);
    } finally {
      emit(AuthState.idle(status: state.status));
    }
  }

  Future<void> _signInWithEmailAndPassword(
    _SignInWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.processing(status: state.status));

    try {
      await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      emit(const AuthState.idle(status: AuthenticationStatus.authenticated));
    } on Object catch (e, stackTrace) {
      emit(
        AuthState.error(
          status: AuthenticationStatus.unauthenticated,
          message: e.toString(),
        ),
      );
      onError(e, stackTrace);
    } finally {
      emit(AuthState.idle(status: state.status));
    }
  }
}

/// Events for [AuthBloc]
sealed class AuthEvent {
  const AuthEvent();

  /// Event to sign in with Email and Password
  const factory AuthEvent.signInWithEmailAndPassword({
    required String email,
    required String password,
  }) = _SignInWithEmailAndPassword;

  /// Event to sign out
  const factory AuthEvent.signOut() = _SignOut;
}

final class _SignInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  const _SignInWithEmailAndPassword({
    required this.email,
    required this.password,
  });
}

final class _SignOut extends AuthEvent {
  const _SignOut();
}

/// States for [AuthBloc]
sealed class AuthState {
  const AuthState({required this.status});

  /// Status of the authentication
  final AuthenticationStatus status;

  /// Idle state, state machine is doing nothing
  const factory AuthState.idle({
    required AuthenticationStatus status,
  }) = _AuthStateIdle;

  const factory AuthState.processing({
    required AuthenticationStatus status,
  }) = _AuthStateProcessing;

  const factory AuthState.error({
    required AuthenticationStatus status,
    required String message,
  }) = _AuthStateError;
}

final class _AuthStateIdle extends AuthState {
  const _AuthStateIdle({required super.status});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _AuthStateIdle && other.status == status;
  }

  @override
  int get hashCode => Object.hashAll([status]);

  @override
  String toString() => '_AuthStateIdle(status: $status)';
}

final class _AuthStateProcessing extends AuthState {
  const _AuthStateProcessing({required super.status});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _AuthStateProcessing && other.status == status;
  }

  @override
  int get hashCode => Object.hashAll([status]);

  @override
  String toString() => '_AuthStateProcessing(status: $status)';
}

final class _AuthStateError extends AuthState {
  final Object message;

  const _AuthStateError({
    required this.message,
    required super.status,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _AuthStateError &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hashAll([status, message]);

  @override
  String toString() => '_AuthStateError(status: $status, message: $message)';
}
