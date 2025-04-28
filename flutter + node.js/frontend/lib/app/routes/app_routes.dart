import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';
import 'package:py_sync/ui/screens/auth/auth_screen.dart';
import 'package:py_sync/ui/screens/dashboard/dashboard_screen.dart';
import 'package:py_sync/ui/screens/dashboard/view/device_management_view.dart';
import 'package:py_sync/ui/screens/dashboard/view/recent_errors_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'routes.dart';
part 'app_routes.g.dart';

/// App routes and navigation configuration
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Singleton instance
  static final AppRoutes I = AppRoutes._();

  // Global key for accessing scaffold messengers throughout the app
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final shellNavigatorKey = GlobalKey<NavigatorState>();

  final rootNavigatorKey = GlobalKey<NavigatorState>();

  // GoRouter configuration
  routerConfig(AuthRepository authRepo) => GoRouter(
    routes: $appRoutes,
    initialLocation: AppPaths.dashboard,
    navigatorKey: rootNavigatorKey,
    refreshListenable: _AuthStateRefreshNotifier(authRepo),
    redirect: _routerRedirect,

    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Route not found: ${state.error}'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  GoRouter.of(context).go(AppPaths.dashboard);
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<String?> _routerRedirect(BuildContext context, GoRouterState state) async {
  final authRepo = context.read<AuthRepository>();

  bool isUserAuthorized = authRepo.state != null;
  bool isOnAuthPage = state.matchedLocation == AppPaths.auth;

  if (isUserAuthorized) {
    return isOnAuthPage ? AppPaths.dashboard : null;
  } else {
    return isOnAuthPage ? null : AppPaths.auth;
  }
}

/// Notifier that triggers router refresh when auth state changes
class _AuthStateRefreshNotifier extends ChangeNotifier {
  final AuthRepository authRepo;
  _AuthStateRefreshNotifier(this.authRepo) {
    // Listen for changes in auth state
    sub = authRepo.stream.listen(_onAuthChanged);
  }
  late final StreamSubscription sub;

  void _onAuthChanged(_) {
    notifyListeners();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}
