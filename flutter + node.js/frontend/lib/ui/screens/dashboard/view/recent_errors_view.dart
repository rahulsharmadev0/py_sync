import 'package:flutter/material.dart';
import 'package:flutter_suite/flutter_suite.dart';
import 'package:py_sync/logic/models/device.dart';
import 'package:py_sync/ui/screens/dashboard/bloc/device_bloc.dart';

import 'package:py_sync/ui/screens/dashboard/view/common.dart';
import 'package:py_sync/ui/screens/dashboard/view/pagination_controls.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentErrorsView extends StatelessWidget {
  const RecentErrorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceState = context.select((DeviceBloc bloc) => bloc.state);
    final devices = deviceState.devices.where(
      (device) => device.syncStatusCode != SyncStatusCode.success,
    );

    return Column(
      children: [
        // Header
        TableHeader(
          headers: [
            (text: 'Device ID', flex: 2),
            (text: 'Error Message', flex: 4),
            (text: 'Last Attempt', flex: 3),
            if (context.$size.width > 800) (text: 'Status', flex: 1),
          ],
        ),

        // Add pagination controls
        TableBody(rows: devices.map(buildErrorRow).toList()),

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

  Widget buildErrorRow(Device device) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    child: Row(
      children: [
        Expanded(flex: 2, child: DeviceIdCell(device)),
        Expanded(
          flex: 4,
          child: Text(
            device.errorMessage ?? '${device.syncStatusCode.name} Error',
            style: TextStyle(color: Colors.red[700]),
          ),
        ),
        Expanded(flex: 3, child: FormetDateTime(device.lastAttemptAt)),
        Builder(
          builder: (context) {
            return (context.$size.width > 800)
                ? Expanded(flex: 1, child: _buildStatusIcon(device.syncStatusCode))
                : SizedBox.shrink();
          },
        ),
      ],
    ),
  );

  Widget _buildStatusIcon(SyncStatusCode status) => switch (status) {
    SyncStatusCode.success => Icon(
      Icons.check_circle,
      color: Colors.green[700],
      size: 18,
    ),
    SyncStatusCode.syncing => Icon(Icons.sync, color: Colors.blue[700], size: 18),
    SyncStatusCode.badRequest => Icon(Icons.error, color: Colors.red[700], size: 18),
    SyncStatusCode.notFound => Icon(Icons.timer_off, color: Colors.orange[700], size: 18),
    SyncStatusCode.serverError => Icon(
      Icons.signal_wifi_off,
      color: Colors.grey[700],
      size: 18,
    ),
    SyncStatusCode.unknown => Icon(Icons.help_outline, color: Colors.grey[700], size: 18),
  };
}
