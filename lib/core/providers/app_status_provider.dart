import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStatus {
  final bool isLoading;
  final String? errorMessage;

  const AppStatus({
    this.isLoading = false,
    this.errorMessage,
  });

  AppStatus copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AppStatus(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AppStatusNotifier extends StateNotifier<AppStatus> {
  AppStatusNotifier() : super(const AppStatus());

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void setError(String message) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: message,
    );
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  void reset() {
    state = const AppStatus();
  }
}

final appStatusProvider = StateNotifierProvider<AppStatusNotifier, AppStatus>((ref) {
  return AppStatusNotifier();
});
