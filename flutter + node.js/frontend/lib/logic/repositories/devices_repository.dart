import 'dart:async';

import 'package:py_sync/logic/models/device.dart';
import 'package:py_sync/logic/utils/repository_utils.dart';

abstract class DevicesRepository extends CachedState<List<Device>>
    with ErrorHandlingMixin {
  DevicesRepository(super.state);

  FutureOr<List<Device>> getAllDevices();

  FutureOr<Device> syncDeviceById(String deviceId);
}
