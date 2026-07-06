import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_ticketing_helpdesk/core/providers/supabase_client_provider.dart';
import 'package:e_ticketing_helpdesk/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:e_ticketing_helpdesk/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:e_ticketing_helpdesk/features/auth/domain/entities/user_entity.dart';
import 'package:e_ticketing_helpdesk/features/auth/domain/repositories/auth_repository.dart';
import 'package:e_ticketing_helpdesk/features/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:e_ticketing_helpdesk/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_ticketing_helpdesk/features/auth/domain/usecases/logout_usecase.dart';
import 'package:e_ticketing_helpdesk/features/auth/domain/usecases/register_usecase.dart';
import 'package:e_ticketing_helpdesk/features/auth/domain/usecases/reset_password_usecase.dart';

final authDataSourceProvider = Provider<SupabaseAuthDataSource>((ref) {
  return SupabaseAuthDataSourceImpl(ref.read(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final getCurrentSessionUseCaseProvider = Provider<GetCurrentSessionUseCase>((ref) {
  return GetCurrentSessionUseCase(ref.read(authRepositoryProvider));
});

final currentSessionProvider = FutureProvider<SessionResult>((ref) async {
  return ref.read(getCurrentSessionUseCaseProvider).execute();
});

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final session = await ref.read(getCurrentSessionUseCaseProvider).execute();
  return session.isAuthenticated;
});

/// Holds the currently signed-in user for the active app session.
///
/// Set after a successful login and cleared on logout so presentation
/// screens can access the user id and role without re-fetching the session.
final currentUserProvider = StateProvider<UserEntity?>((ref) => null);
