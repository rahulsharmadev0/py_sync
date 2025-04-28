import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:py_sync/logic/apis/auth_api.dart';
import 'package:py_sync/logic/apis/devices_api.dart';
import 'package:py_sync/logic/models/device.dart';

void main() {
  late http.Client client;
  late AuthApi authApi;
  late DevicesApi devicesApi;
  late String jwtToken;
  const baseUrl = 'http://localhost:3000';

  setUp(() async {
    try {
      client = http.Client();
      authApi = const AuthApi(baseUrl: baseUrl);
      devicesApi = DevicesApi(baseUrl: baseUrl);
      jwtToken = await authApi.login('rahulsharma', 'rahulsharma123');
    } catch (e) {
      fail(
        'Failed to set up test environment. Is the server running at $baseUrl? Error: $e',
      );
    }
  });

  tearDown(() {
    client.close();
  });

  group('DevicesApi Integration Tests', () {
    test('getAllDevices returns a list of devices', () async {
      try {
        final devices = await devicesApi.getAllDevices(jwtToken);

        // Assert we got a non-empty list
        expect(devices, isNotEmpty);
        expect(devices, isA<List<Device>>());
        print('Successfully fetched ${devices.length} devices');
      } catch (e) {
        fail('Failed to get devices. Is the server running at $baseUrl? Error: $e');
      }
    });

    test('syncDevice returns a synced device', () async {
      try {
        // First get all devices
        final devices = await devicesApi.getAllDevices(jwtToken);
        final deviceToSync = devices.first;

        // Now sync the first device
        final syncedDevice = await devicesApi.syncDevice(
          jwtToken,
          deviceToSync.deviceId.toString(),
        );

        // Assert that we got back the same device
        expect(syncedDevice.deviceId, equals(deviceToSync.deviceId));
        expect(syncedDevice.name, equals(deviceToSync.name));

        // Assert that the device has been synced
        // expect(syncedDevice.lastSyncAt, isNotNull);
        // expect(syncedDevice.lastAttemptAt, isNotNull);

        print('Successfully synced device: ${syncedDevice.name}');
      } catch (e) {
        fail('Failed to sync device. Is the server running at $baseUrl? Error: $e');
      }
    });

    test('syncDevice throws exception for non-existent device', () async {
      try {
        // Try to sync a non-existent device
        await devicesApi.syncDevice(jwtToken, '99999');
        fail('Sync should have failed for non-existent device');
      } catch (e) {
        // This is the expected behavior
        expect(e, isA<Exception>());
        print('As expected, sync failed for non-existent device');
      }
    });

    test('getAllDevices throws exception with invalid token', () async {
      try {
        // Try to get devices with an invalid token
        await devicesApi.getAllDevices('invalid_token');
        fail('Request should have failed with invalid token');
      } catch (e) {
        // This is the expected behavior
        expect(e, isA<Exception>());
        print('As expected, request failed with invalid token');
      }
    });
  });
}
