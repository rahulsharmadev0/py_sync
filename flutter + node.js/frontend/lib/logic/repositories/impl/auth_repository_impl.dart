import 'dart:async';

import 'package:py_sync/logic/apis/auth_api.dart';
import 'package:py_sync/logic/models/user.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthApi authApi;
  AuthRepositoryImpl({required User? initalValue, required this.authApi})
    : super(initalValue);

  @override
  FutureOr<User> register(String username, String password) async {
    if (state != null) return state!;
    return handleErrors(() async {
      var jwtToken = await authApi.register(username, password);
      var newState = User(username: username, jwtToken: jwtToken);
      emit(newState);
      return newState;
    }, errorPrefix: 'Registration failed:');
  }

  @override
  FutureOr<User> login(String username, String password) async {
    if (state != null) return state!;
    return handleErrors(() async {
      var jwtToken = await authApi.register(username, password);
      var newState = User(username: username, jwtToken: jwtToken);
      emit(newState);
      return newState;
    }, errorPrefix: 'Login failed:');
  }

  @override
  Map<String, dynamic>? toJson(User? state) => state?.toJson();

  @override
  User? fromJson(Map<String, dynamic>? json) => json == null ? null : User.fromJson(json);
}
