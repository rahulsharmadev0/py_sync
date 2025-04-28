import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';
import 'package:py_sync/logic/repositories/devices_repository.dart';
import 'package:py_sync/ui/screens/dashboard/bloc/device_bloc.dart';
import 'package:py_sync/ui/screens/dashboard/view/device_management_view.dart';
import 'package:py_sync/ui/screens/dashboard/view/recent_errors_view.dart';

class DashboardNavigationBar extends StatelessWidget {
  final void Function(int n)? onSelect;
  const DashboardNavigationBar({super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        clipBehavior: Clip.hardEdge,
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black54,
          onTap: onSelect,
          controller: DashboardState.of(context)._tabController,
          tabs: [Tab(text: 'Device Management'), Tab(text: 'Recent Errors')],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardState();
}

class DashboardState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static DashboardState of(BuildContext context) {
    return context.findAncestorStateOfType<DashboardState>()!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              DeviceBloc(context.read<DevicesRepository>())..add(RefreshDeviceEvent()),
      child: BlocListener<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state.status == DeviceStatus.error) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Unknown error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/brand.png',
                  height: 40,
                  colorBlendMode: BlendMode.srcIn,
                  color: Colors.white,
                ),
                const Text('Sync Dashboard'),
              ],
            ),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              return Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 42,
                        child: Row(
                          children: [
                            DashboardNavigationBar(),
                            Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                var read = context.read<DeviceBloc>();
                                return read.add(RefreshDeviceEvent());
                              },
                              icon:
                                  state.status == DeviceStatus.syncing
                                      ? CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      )
                                      : const Icon(Icons.refresh, color: Colors.black),
                              label: Text(
                                'Refresh',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: context.read<AuthRepository>().signOut,
                              icon: const Icon(Icons.logout, color: Colors.black),
                              label: Text(
                                'Logout',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: const [DeviceManagementView(), RecentErrorsView()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
