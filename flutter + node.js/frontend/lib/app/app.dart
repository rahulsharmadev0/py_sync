import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:py_sync/app/routes/app_routes.dart';
import 'package:py_sync/app/theme.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';

/// Main application widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    var authRepo = context.read<AuthRepository>();
    return MaterialApp.router(
      scaffoldMessengerKey: AppRoutes.I.scaffoldMessengerKey,
      title: 'PySync Admin Panel',
      theme: AppTheme.light,
      routerConfig: AppRoutes.I.routerConfig(authRepo),
      debugShowCheckedModeBanner: false,
    );
  }
}
