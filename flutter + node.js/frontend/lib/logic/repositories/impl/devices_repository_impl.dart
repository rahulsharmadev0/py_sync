import 'dart:async';
import 'package:py_sync/logic/apis/devices_api.dart';
import 'package:py_sync/logic/models/device.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';
import 'package:py_sync/logic/repositories/devices_repository.dart';

class DevicesRepositoryImpl extends DevicesRepository {
  final DevicesApi devicesApi;
  DevicesRepositoryImpl({List<Device>? initalValue, required this.devicesApi})
    : super(initalValue ?? []);

  @override
  FutureOr<List<Device>> getAllDevices() async {
    var jwtToken = AuthRepository.currentUser?.jwtToken;
    if (jwtToken == null) {
      throw Exception('User is not logged in');
    }

    return handleErrorsAndRetry(() async {
      final response = await devicesApi.getAllDevices(jwtToken);

      // Handle different response formats
      List<Device> devices = [];
      if (response['data'] != null) {
        devices =
            (response['data'] as List).map((item) => Device.fromJson(item)).toList();
      } else if (response['devices'] != null) {
        devices =
            (response['devices'] as List).map((item) => Device.fromJson(item)).toList();
      } else {
        // If neither data nor devices field exists, try to find any list in the response
        final possibleDevicesField = response.entries.firstWhere(
          (entry) => entry.value is List && entry.value.isNotEmpty,
          orElse: () => const MapEntry('', []),
        );

        if (possibleDevicesField.value is List && possibleDevicesField.value.isNotEmpty) {
          devices =
              (possibleDevicesField.value as List)
                  .map((item) => Device.fromJson(item))
                  .toList();
        }
      }

      emit(devices);
      return devices;
    }, errorPrefix: 'Failed to fetch devices');
  }

  @override
  FutureOr<PaginatedDevicesResponse> getDevicesWithPagination({
    int page = 1,
    int limit = 10,
    String? syncStatusCode,
    String? sortBy,
    String? order,
  }) async {
    var jwtToken = AuthRepository.currentUser?.jwtToken;
    if (jwtToken == null) {
      throw Exception('User is not logged in');
    }

    return handleErrorsAndRetry(() async {
      final response = await devicesApi.getAllDevices(
        jwtToken,
        page: page,
        limit: limit,
        syncStatusCode: syncStatusCode,
        sortBy: sortBy,
        order: order,
      );

      // Handle different response formats
      List<Device> devices = [];
      if (response['data'] != null) {
        devices =
            (response['data'] as List).map((item) => Device.fromJson(item)).toList();
      } else if (response['devices'] != null) {
        devices =
            (response['devices'] as List).map((item) => Device.fromJson(item)).toList();
      } else {
        // If neither data nor devices field exists, try to find any list in the response
        final possibleDevicesField = response.entries.firstWhere(
          (entry) => entry.value is List && entry.value.isNotEmpty,
          orElse: () => const MapEntry('', []),
        );

        if (possibleDevicesField.value is List && possibleDevicesField.value.isNotEmpty) {
          devices =
              (possibleDevicesField.value as List)
                  .map((item) => Device.fromJson(item))
                  .toList();
        }
      }

      // Only update the state if we're on the first page
      if (page == 1) {
        emit(devices);
      }

      return PaginatedDevicesResponse(
        devices: devices,
        currentPage: response['page'] ?? 1,
        totalPages: response['totalPages'] ?? 1,
        totalItems: response['totalItems'] ?? devices.length,
        limit: response['limit'] ?? limit,
      );
    }, errorPrefix: 'Failed to fetch devices');
  }

  @override
  FutureOr<Device> syncDeviceById(String deviceId) async {
    var jwtToken = AuthRepository.currentUser?.jwtToken;
    if (jwtToken == null) {
      throw Exception('User is not logged in');
    }
    return handleErrorsAndRetry(() async {
      final device = await devicesApi.syncDevice(jwtToken, deviceId);

      final index = state.indexWhere((d) => d.deviceId == device.deviceId);
      if (index != -1) {
        state[index] = device;
      } else {
        state.add(device); // This case should not happen, but just in case
      }
      return device;
    }, errorPrefix: 'Failed to fetch device');
  }

  // Remove @override annotations as these are not overriding any methods
  List<Device>? fromJson(Map<String, dynamic> json) {
    final List<dynamic> deviceList = json['devices'] ?? [];
    return deviceList.map((deviceJson) => Device.fromJson(deviceJson)).toList();
  }

  Map<String, dynamic>? toJson(List<Device> state) {
    return {'devices': state.map((device) => device.toJson()).toList()};
  }
}
