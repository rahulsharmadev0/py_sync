import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:py_sync/logic/apis/auth_api.dart';

void main() {
  late http.Client client;
  late AuthApi authApi;
  final baseUrl = 'http://localhost:3000';

  setUp(() {
    client = http.Client();
    authApi = AuthApi(baseUrl: baseUrl);
  });

  tearDown(() {
    client.close();
  });

  group('AuthApi Integration Tests', () {
    test('register returns token on successful response', () async {
      try {
        // Using a unique username to avoid conflicts
        final username = 'testuser_${DateTime.now().millisecondsSinceEpoch}';
        final token = await authApi.register(username, 'password123');

        // Assert that we got a non-empty token
        expect(token, isNotEmpty);
        print('Successfully registered user: $username');
      } catch (e) {
        // If the server is not running, this will make the test more informative
        fail('Failed to register user. Is the server running at $baseUrl? Error: $e');
      }
    });

    test('login returns token for existing user', () async {
      try {
        // Create a user first
        final username = 'logintest_${DateTime.now().millisecondsSinceEpoch}';
        await authApi.register(username, 'password123');

        // Now try to login
        final token = await authApi.login(username, 'password123');

        // Assert that we got a non-empty token
        expect(token, isNotEmpty);
        print('Successfully logged in user: $username');
      } catch (e) {
        fail('Failed to login. Is the server running at $baseUrl? Error: $e');
      }
    });

    test('login throws exception for invalid credentials', () async {
      try {
        // Try to login with invalid credentials
        await authApi.login('nonexistentuser', 'wrongpassword');
        fail('Login should have failed for invalid credentials');
      } catch (e) {
        // This is the expected behavior
        expect(e, isA<Exception>());
        print('As expected, login failed for invalid credentials');
      }
    });
  });
}
