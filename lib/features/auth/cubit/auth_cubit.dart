import 'package:combustivel_ap/features/auth/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signIn(
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUp(
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(Unauthenticated());
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await authRepository.checkSession();
      if (user == null) {
        emit(Unauthenticated());
        return;
      }
      
      emit(Authenticated(user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> toggleFavoriteFuelType(String? fuelType) async {
    final currentState = state;
    if (currentState is Authenticated) {
      final newFuelType = currentState.user.favoriteFuelType == fuelType ? null : fuelType;
      await authRepository.updateFavoriteFuelType(newFuelType);
      final updatedUser = UserModel(
        uid: currentState.user.uid,
        email: currentState.user.email,
        isAdmin: currentState.user.isAdmin,
        favoriteFuelType: newFuelType,
        favoriteStationId: currentState.user.favoriteStationId,
      );
      emit(Authenticated(updatedUser));
    }
  }

  Future<void> toggleFavoriteStation(String? stationId) async {
    final currentState = state;
    if (currentState is Authenticated) {
      final newStationId = currentState.user.favoriteStationId == stationId ? null : stationId;
      await authRepository.updateFavoriteStation(newStationId);
      final updatedUser = UserModel(
        uid: currentState.user.uid,
        email: currentState.user.email,
        isAdmin: currentState.user.isAdmin,
        favoriteFuelType: currentState.user.favoriteFuelType,
        favoriteStationId: newStationId,
      );
      emit(Authenticated(updatedUser));
    }
  }
}
