import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signIn(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signUp(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await authRepository.signOut();
      emit(Unauthenticated());
    });
  }
}
