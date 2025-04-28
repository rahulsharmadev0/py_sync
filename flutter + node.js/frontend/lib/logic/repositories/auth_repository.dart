import 'dart:async';

import 'package:py_sync/logic/models/user.dart';
import 'package:py_sync/logic/utils/repository_utils.dart';

abstract class AuthRepository extends CachedState<User?> with ErrorHandlingMixin {
  AuthRepository(super.state);

  static User? currentUser;

  FutureOr<void> register(String username, String password);

  FutureOr<void> login(String username, String password);

  FutureOr<void> signOut() async =>
      UnimplementedError('signOut() has not been implemented.');
}
