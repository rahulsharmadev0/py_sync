import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:py_sync/logic/models/device.dart';
import 'package:py_sync/logic/repositories/devices_repository.dart';

sealed class DeviceEvent {
  const DeviceEvent();
}

class RefreshDeviceEvent extends DeviceEvent {}

class SyncSingleDeviceEvent extends DeviceEvent {
  final String deviceId;
  SyncSingleDeviceEvent(this.deviceId);
}

enum DeviceStatus { idle, syncing, synced, error }

class DeviceState {
  final DeviceStatus status;
  final List<Device> devices;
  final String? errorMessage;
  const DeviceState({required this.status, this.devices = const [], this.errorMessage});

  const DeviceState.initial() : this(status: DeviceStatus.idle);

  DeviceState copyWith({
    DeviceStatus? status,
    List<Device>? devices,
    String? errorMessage,
  }) {
    return DeviceState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DevicesRepository devicesRepos;

  DeviceBloc(this.devicesRepos) : super(DeviceState.initial()) {
    on<RefreshDeviceEvent>(_handleRefreshDevices);
    on<SyncSingleDeviceEvent>(_handleSyncDevice);
  }

  /// Handles the refresh devices event by fetching all devices
  Future<void> _handleRefreshDevices(
    RefreshDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    // Skip if already loading
    if (state.status == DeviceStatus.syncing) return;

    emit(state.copyWith(status: DeviceStatus.syncing));

    try {
      final devices = await devicesRepos.getAllDevices();
      emit(state.copyWith(status: DeviceStatus.synced, devices: devices));
    } catch (e) {
      emit(
        state.copyWith(
          status: DeviceStatus.error,
          errorMessage: 'Failed to fetch devices: $e',
        ),
      );
    }
  }

  /// Handles syncing a single device by ID
  Future<void> _handleSyncDevice(
    SyncSingleDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    // Skip if loading or not in loaded state
    if (state.status == DeviceStatus.syncing || state.status != DeviceStatus.synced) {
      return;
    }
    List<Device> devices = [...state.devices];

    try {
      int intex = -1;
      for (var (i, device) in devices.indexed) {
        if (device.deviceId == event.deviceId) {
          intex = i;
          break;
        }
      }

      if (intex == -1) {
        emit(
          state.copyWith(status: DeviceStatus.error, errorMessage: 'Device not found'),
        );
        return;
      }
      devices[intex] = devices[intex].copyWith(
        syncStatusCode: SyncStatusCode.syncing,
        lastAttemptAt: DateTime.now(),
      );
      emit(state.copyWith(devices: devices));

      try {
        var d = await devicesRepos.syncDeviceById(event.deviceId);
        devices[intex] = d.copyWith(syncStatusCode: SyncStatusCode.success);
      } catch (e) {
        devices[intex] = devices[intex].copyWith(
          syncStatusCode: SyncStatusCode.serverError,
          errorMessage: e.toString(),
        );
      } finally {
        emit(state.copyWith(devices: devices));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DeviceStatus.error,
          errorMessage: 'Failed to sync device: $e',
        ),
      );
    }
  }
}
