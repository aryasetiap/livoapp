import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(Supabase.instance.client);
});

class UserRepository {
  final SupabaseClient _supabase;

  UserRepository(this._supabase);

  Future<UserModel?> getUser(String id) async {
    try {
      final data = await _supabase.from('users').select().eq('id', id).single();
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    await _supabase.from('users').update(user.toJson()).eq('id', user.id);
  }
}
