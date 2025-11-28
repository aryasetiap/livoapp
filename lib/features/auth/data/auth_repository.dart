import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livoapp/features/auth/domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

class AuthRepository {
  final SupabaseClient _supabase;
  GoTrueClient get _auth => _supabase.auth;

  AuthRepository(this._supabase);

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  User? get currentUser => _auth.currentUser;

  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    return await _auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.resetPasswordForEmail(email);
  }

  Future<void> followUser(String userId) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return;

    await _supabase.from('followers').insert({
      'follower_id': currentUserId,
      'following_id': userId,
    });
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
        .single();

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
}
