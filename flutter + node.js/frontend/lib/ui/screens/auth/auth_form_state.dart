enum FormStatus { login, register }

class AuthFormState {
  // Form fields
  final String username;
  final String password;

  final FormStatus formStatus; // Current Active Form (Login/Register)
  final bool isLoading; // Loading state for the form
  final String? errorMessage; // Error message if any

  AuthFormState({
    this.formStatus = FormStatus.login,
    this.isLoading = false,
    this.errorMessage,
    this.username = '',
    this.password = '',
  });

  AuthFormState copyWith({
    FormStatus? formStatus,
    bool? isLoading,
    String? errorMessage,
    String? username,
    String? password,
  }) => AuthFormState(
    formStatus: formStatus ?? this.formStatus,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
    username: username ?? this.username,
    password: password ?? this.password,
  );

  bool isValid() =>
      username.isNotEmpty &&
      password.isNotEmpty &&
      username.length >= 3 &&
      password.length >= 6 &&
      (formStatus == FormStatus.login || formStatus == FormStatus.register);
}
