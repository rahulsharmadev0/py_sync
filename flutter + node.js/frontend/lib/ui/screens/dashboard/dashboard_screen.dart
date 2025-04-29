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
      height: 42,
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
              var children = [
                DashboardNavigationBar(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed:
                          () => context.read<DeviceBloc>().add(RefreshDeviceEvent()),
                      icon: Icon(Icons.refresh, color: Colors.black),
                      label: Text('Refresh', style: TextStyle(color: Colors.black)),
                    ),

                    TextButton.icon(
                      onPressed: context.read<AuthRepository>().signOut,
                      icon: Icon(Icons.logout, color: Colors.black),
                      label: Text('Logout', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ];
              var width = MediaQuery.sizeOf(context).width;
              return Center(
                child: SizedBox(
                  width: width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      width > 800
                          ? Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: children,
                          )
                          : Column(children: children),

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
