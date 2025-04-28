import 'dart:async';

import 'package:py_sync/logic/apis/auth_api.dart';
import 'package:py_sync/logic/models/user.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthApi authApi;
  AuthRepositoryImpl({required User? initalValue, required this.authApi})
    : super(initalValue) {
    AuthRepository.currentUser = state;
  }

  @override
  FutureOr<User> register(String username, String password) async {
    if (state != null) return AuthRepository.currentUser = state!;
    return handleErrors(() async {
      var jwtToken = await authApi.register(username, password);
      var newState = User(username: username, jwtToken: jwtToken);
      emit(newState);
      return AuthRepository.currentUser = newState;
    }, errorPrefix: 'Registration failed:');
  }

  @override
  FutureOr<User> login(String username, String password) async {
    if (state != null) return AuthRepository.currentUser = state!;
    return handleErrors(() async {
      var jwtToken = await authApi.login(username, password);
      var newState = User(username: username, jwtToken: jwtToken);
      emit(newState);

      return AuthRepository.currentUser = newState;
    }, errorPrefix: 'Login failed:');
  }

  @override
  Map<String, dynamic>? toJson(User? state) => state?.toJson();

  @override
  User? fromJson(Map<String, dynamic>? json) => json == null ? null : User.fromJson(json);

  @override
  FutureOr<void> signOut() {
    emit(null);
    AuthRepository.currentUser = null;
  }
}
