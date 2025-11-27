import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.read(authRepositoryProvider));
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }
}
