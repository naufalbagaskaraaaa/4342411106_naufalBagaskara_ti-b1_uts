import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// Supabase implementation of authentication data source
/// Handles all direct Supabase authentication operations
abstract class SupabaseAuthDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String nama, String role);
  Future<UserModel> updateProfile(String userId, {String? nama, String? email});
  Future<bool> resetPassword(String email);
  Future<bool> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
}

class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AppAuthException('Login failed: Invalid credentials');
      }

      // Fetch additional user data from users table
      final userData = await supabaseClient
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(userData);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String nama, String role) async {
    try {
      // First create auth user
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'nama': nama,
          'role': role,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AppAuthException('Registration failed: Could not create user');
      }

      // Create user record in users table
      await supabaseClient.from(SupabaseConstants.usersTable).insert({
        'id': user.id,
        'email': email,
        'nama': nama,
        'role': role,
      });

      // Fetch the created user data
      final userData = await supabaseClient
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(userData);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> resetPassword(String email) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      throw AppAuthException('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile(
    String userId, {
    String? nama,
    String? email,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (nama != null && nama.trim().isNotEmpty) {
        updateData['nama'] = nama.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        updateData['email'] = email.trim();
      }

      if (updateData.isEmpty) {
        throw const AppAuthException('No profile fields provided to update');
      }

      final response = await supabaseClient
          .from(SupabaseConstants.usersTable)
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw AppAuthException('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await supabaseClient.auth.signOut();
      return true;
    } catch (e) {
      throw AppAuthException('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      // Fetch additional user data from users table
      final userData = await supabaseClient
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = supabaseClient.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }
}
