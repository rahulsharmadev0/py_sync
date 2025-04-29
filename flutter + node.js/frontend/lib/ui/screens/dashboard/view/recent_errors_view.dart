import 'package:flutter/material.dart';
import 'package:flutter_suite/flutter_suite.dart';
import 'package:py_sync/logic/models/device.dart';
import 'package:py_sync/logic/models/log.dart';
import 'package:py_sync/ui/screens/dashboard/bloc/common_state_events.dart';
import 'package:py_sync/ui/screens/dashboard/bloc/error_logs_bloc.dart';

import 'package:py_sync/ui/screens/dashboard/view/common.dart';
import 'package:py_sync/ui/screens/dashboard/view/pagination_controls.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentErrorsView extends StatelessWidget {
  const RecentErrorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceState = context.select((ErrorLogsBloc bloc) => bloc.state);
    final devices = deviceState.logs;
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
            context.read<ErrorLogsBloc>().add(LoadPageEvent(page));
          },
        ),
      ],
    );
  }

  Widget buildErrorRow(Log log) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: DeviceIdCell(log.deviceId, deviceName: log.name, deviceType: log.type),
        ),
        Expanded(
          flex: 4,
          child: Text(
            log.errorMessage ?? 'Unknown error',
            style: TextStyle(color: Colors.red[700]),
          ),
        ),
        Expanded(flex: 3, child: FormetDateTime(log.lastAttemptAt)),
        Builder(
          builder: (context) {
            return (context.$size.width > 800)
                ? Expanded(
                  flex: 1,
                  child: Row(children: [_buildStatusIcon(log.errorMessage)]),
                )
                : SizedBox.shrink();
          },
        ),
      ],
    ),
  );

  Widget _buildStatusIcon(String? status) => switch (status) {
    'Unknown Sync Error' => Icon(
      Icons.sync_disabled,
      color: Colors.blueGrey[700],
      size: 18,
    ),
    'Server Not Reachable' => Icon(Icons.error, color: Colors.red[700], size: 18),
    'Connection Timeout' => Icon(Icons.timer_off, color: Colors.orange[700], size: 18),
    _ => Icon(Icons.help_outline, color: Colors.grey[700], size: 18),
  };
}
