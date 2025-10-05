import 'package:farmmatrix/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get user data by user ID
  Future<UserModel> getUserData(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Get current logged-in user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromMap(response);
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }

  
}