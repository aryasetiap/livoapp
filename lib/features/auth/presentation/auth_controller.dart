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
    state = await AsyncValue.guard(() async {
      final result = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save FCM token after successful sign in
      if (result.user != null) {
        await _authRepository.saveFcmToken();
        await _authRepository.setupFcmListeners();
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
      );

      // Save FCM token after successful sign up
      if (result.user != null) {
        await _authRepository.saveFcmToken();
        await _authRepository.setupFcmListeners();
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _authRepository.signInWithGoogle();

      // Save FCM token after successful sign in
      if (result.user != null) {
        await _authRepository.saveFcmToken();
        await _authRepository.setupFcmListeners();
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }

  Future<void> resetPassword({required String email}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.resetPassword(email: email),
    );
  }
}
