import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lvoapp/features/auth/domain/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lvoapp/features/notifications/data/notification_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    Supabase.instance.client,
    ref.read(notificationRepositoryProvider),
  );
});

class AuthRepository {
  final SupabaseClient _supabase;
  final NotificationRepository _notificationRepository;
  GoTrueClient get _auth => _supabase.auth;

  AuthRepository(this._supabase, this._notificationRepository);

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  User? get currentUser => _auth.currentUser;

  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Strict Check: Is email confirmed?
    final user = response.user;
    if (user != null && user.emailConfirmedAt == null) {
      // If unverified, force sign out immediately to prevent access
      await _auth.signOut();
      throw 'Email belum diverifikasi. Silakan cek inbox/spam email Anda untuk link verifikasi.';
    }

    return response;
  }

  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
      emailRedirectTo: 'io.supabase.lvoapp://verified',
    );

    // Previously we forced signOut() here, but that DELETES the PKCE verifier code,
    // causing "AuthException: Code verifier could not be found" when clicking the email link.
    // We now rely on Router logic to prevent access if unverified.

    return response;
  }

  static const _webClientId =
      '234253323510-j6qrjvbh8i787c5v5r9spb9r78k175hc.apps.googleusercontent.com';

  Future<AuthResponse> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw 'Google Sign In canceled';
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    final response = await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    // Ensure profile is created immediately after Google Login
    if (response.user != null) {
      await ensureProfileExists();
    }

    return response;
  }

  /// Ensures a profile exists for the current user.
  /// Creates one using metadata if missing.
  Future<void> ensureProfileExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Check if profile exists using maybeSingle to avoid exception
      final data = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // Create profile from user metadata
        final metadata = user.userMetadata;
        final name =
            metadata?['full_name'] ??
            metadata?['name'] ??
            user.email?.split('@')[0] ??
            'User';
        final username =
            metadata?['preferred_username'] ??
            name.toString().replaceAll(' ', '').toLowerCase();
        // final avatarUrl = metadata?['avatar_url'] ?? metadata?['picture']; // Optional

        debugPrint('Creating profile for ${user.id}...');
        await _supabase.from('profiles').insert({
          'id': user.id,
          // 'email': user.email, // Column does not exist in DB
          'username': username,
          'full_name': name,
          // 'avatar_url': avatarUrl,
        });
      }
    } catch (e) {
      debugPrint('Error ensuring profile exists: $e');
      // Don't rethrow, strictly existing is "best effort"
    }
  }

  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _webClientId,
      );
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error signing out of Google: $e');
    }
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.lvoapp://reset-callback',
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> followUser(String userId) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return;

    await _supabase.from('followers').insert({
      'follower_id': currentUserId,
      'following_id': userId,
    });

    // Create notification for followed user
    await _notificationRepository.createFollowNotification(
      userId,
      _auth.currentUser?.userMetadata?['username'] ?? 'User',
    );
  }

  Future<void> unfollowUser(String userId) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return;

    await _supabase
        .from('followers')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('following_id', userId);
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .ilike('username', '%$query%')
        .limit(20);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<UserModel> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select(
          '*, followers:followers!following_id(count), following:followers!follower_id(count)',
        )
        .eq('id', userId)
        .maybeSingle(); // Changed from single() to maybeSingle() to handle missing rows

    if (response == null) {
      // Self-Healing: If profile is missing for CURRENT USER, create it.
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.id == userId) {
        final username =
            currentUser.userMetadata?['username'] ??
            currentUser.email?.split('@')[0] ??
            'User';

        // Insert new profile
        // Note: Removed 'created_at' as it might not affect all profile tables or RLS might block it.
        // Supabase should handle this or we rely on 'updated_at' if available.
        final newProfile = {
          'id': userId,
          'username': username,
          'full_name': username,
        };

        try {
          await _supabase.from('profiles').insert(newProfile);
        } catch (e) {
          debugPrint('Failed to auto-create profile: $e');
        }

        // Return constructed model
        return UserModel.fromJson({
          ...newProfile,
          'followers_count': 0,
          'following_count': 0,
          'isFollowing': false,
        });
      }

      throw 'User profile not found';
    }

    // Check if current user is following this user
    bool isFollowing = false;
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId != null && currentUserId != userId) {
      final followCheck = await _supabase
          .from('followers')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .maybeSingle();
      isFollowing = followCheck != null;
    }

    final data = Map<String, dynamic>.from(response);

    // Parse counts
    int followersCount = 0;
    if (data['followers'] != null) {
      final followersList = data['followers'] as List;
      if (followersList.isNotEmpty) {
        followersCount = followersList.first['count'] as int;
      }
    }

    int followingCount = 0;
    if (data['following'] != null) {
      final followingList = data['following'] as List;
      if (followingList.isNotEmpty) {
        followingCount = followingList.first['count'] as int;
      }
    }

    // Add email from auth if it's the current user, or fetch from somewhere else if public (usually email is private)
    // For now, we'll use a placeholder or empty string for email if not available in profiles
    // But UserModel requires email.
    // If it's the current user, we can get it from _auth.currentUser.email
    String email = '';
    if (userId == currentUserId) {
      email = _auth.currentUser?.email ?? '';
    }

    // We need to construct UserModel.
    // Note: UserModel expects 'created_at'. Profiles might not have it if not selected or if column missing.
    // Let's assume profiles has created_at or we use current time as fallback.

    return UserModel.fromJson({
      ...data,
      'email': email, // Inject email
      'followers_count': followersCount,
      'following_count': followingCount,
      'isFollowing': isFollowing,
      'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveFcmToken() async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return;

    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();

      if (token != null) {
        await _supabase
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', currentUserId);
      }
    } catch (e) {
      // Log error but don't fail auth flow
      debugPrint('Failed to save FCM token: $e');
    }
  }

  Future<void> setupFcmListeners() async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Listen for token refresh
    messaging.onTokenRefresh.listen((token) async {
      await _supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', currentUserId);
    });
  }

  Future<List<String>> getFollowedUserIds() async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return [];

    final response = await _supabase
        .from('followers')
        .select('following_id')
        .eq('follower_id', currentUserId);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((e) => e['following_id'] as String).toList();
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final response = await _supabase
        .from('profiles')
        .select('username')
        .eq('username', username.trim())
        .maybeSingle();
    return response == null;
  }
}
