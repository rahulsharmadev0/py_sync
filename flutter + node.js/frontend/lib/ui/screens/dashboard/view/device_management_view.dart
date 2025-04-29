import 'package:bloc_suite/bloc_suite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:py_sync/logic/models/device.dart';
import 'package:py_sync/ui/screens/dashboard/bloc/common_state_events.dart';
import 'package:py_sync/ui/screens/dashboard/bloc/device_bloc.dart';

import 'package:py_sync/ui/screens/dashboard/view/common.dart';
import 'package:py_sync/ui/screens/dashboard/view/pagination_controls.dart';

class DeviceManagementView extends StatelessWidget {
  const DeviceManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceState = context.select((DeviceBloc bloc) => bloc.state);
    final devices = deviceState.devices;

    return Column(
      children: [
        TableHeader(
          headers: [
            (text: 'Device ID', flex: 3),
            (text: 'Last Sync Time', flex: 3),
            (text: 'Status', flex: 2),
            (text: 'Action', flex: 2),
          ],
        ),

        TableBody(rows: devices.map(buildDataRow).toList()),

        // Add pagination controls
        PaginationControls(
          currentPage: deviceState.currentPage,
          totalPages: deviceState.totalPages,
          onPageChanged: (int page) {
            context.read<DeviceBloc>().add(LoadPageEvent(page));
          },
        ),
      ],
    );
  }

  Widget buildDataRow(Device device) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DeviceIdCell(
              device.deviceId,
              deviceName: device.name,
              deviceType: device.type ?? '',
            ),
          ),
          Expanded(flex: 3, child: FormetDateTime(device.lastAttemptAt)),
          Expanded(flex: 2, child: StatusBadge(device.syncStatusCode)),
          Expanded(flex: 2, child: SyncNowButton(device)),
        ],
      ),
    );
  }
}

class SyncNowButton extends BlocSelectorWidget<DeviceBloc, DeviceState, DeviceStatus> {
  final Device device;
  SyncNowButton(this.device, {super.key}) : super(selector: (state) => state.status);

  @override
  Widget build(BuildContext context, bloc, state) {
    bool isLoading = state == DeviceStatus.syncing;
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton(
        onPressed:
            isLoading ? null : () => bloc.add(SyncSingleDeviceEvent(device.deviceId)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child:
            isLoading
                ? SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
                : const Text('Sync Now'),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final SyncStatusCode status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      SyncStatusCode.success => badge('✅ Success', Colors.green[700]!),
      SyncStatusCode.syncing => badge('🔄 Connecting', Colors.blue[700]!),
      SyncStatusCode.serverError => badge('❌ Failed', Colors.red[700]!),
      SyncStatusCode.notFound => badge('⏱️ Timeout', Colors.orange[700]!),
      SyncStatusCode.badRequest => badge('📵 Offline', Colors.grey[700]!),
      SyncStatusCode.unknown => badge('❓ Unknown', Colors.grey[700]!),
    };
  }

  Widget badge(String text, Color color) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
