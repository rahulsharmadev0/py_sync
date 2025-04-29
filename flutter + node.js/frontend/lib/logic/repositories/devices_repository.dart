import 'dart:async';

import 'package:py_sync/logic/models/device.dart';
import 'package:py_sync/logic/utils/repository_utils.dart';

class PaginatedDevicesResponse {
  final List<Device> devices;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;

  PaginatedDevicesResponse({
    required this.devices,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
  });
}

abstract class DevicesRepository extends CachedState<List<Device>>
    with ErrorHandlingMixin {
  DevicesRepository(super.state);

  // The original method (will still be used for compatibility)
  FutureOr<List<Device>> getAllDevices();

  // New method with pagination support
  FutureOr<PaginatedDevicesResponse> getDevicesWithPagination({
    int page = 1,
    int limit = 10,
    String? syncStatusCode,
    String? sortBy,
    String? order,
  });

  FutureOr<Device> syncDeviceById(String deviceId);
}
