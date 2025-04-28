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
    if (state.isNotEmpty) return state;

    return handleErrors(() async {
      final devices = await devicesApi.getAllDevices(jwtToken);
      emit(devices);
      return devices;
    }, errorPrefix: 'Failed to fetch devices');
  }

  @override
  FutureOr<Device> syncDeviceById(String deviceId) async {
    var jwtToken = AuthRepository.currentUser?.jwtToken;
    if (jwtToken == null) {
      throw Exception('User is not logged in');
    }
    return handleErrors(() async {
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

  @override
  List<Device>? fromJson(Map<String, dynamic> json) {
    final List<dynamic> deviceList = json['devices'] ?? [];
    return deviceList.map((deviceJson) => Device.fromJson(deviceJson)).toList();
  }

  @override
  Map<String, dynamic>? toJson(List<Device> state) {
    return {'devices': state.map((device) => device.toJson()).toList()};
  }
}
