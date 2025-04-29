import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:py_sync/app/app.dart';
import 'package:py_sync/app/bootstrap.dart';
import 'package:py_sync/logic/apis/auth_api.dart';
import 'package:py_sync/logic/apis/devices_api.dart';
import 'package:py_sync/logic/apis/logs_api.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';
import 'package:py_sync/logic/repositories/devices_repository.dart';
import 'package:py_sync/logic/repositories/impl/auth_repository_impl.dart';
import 'package:py_sync/logic/repositories/impl/devices_repository_impl.dart';
import 'package:py_sync/logic/repositories/impl/logs_repository_impl.dart';
import 'package:py_sync/logic/repositories/logs_repository.dart';

const baseUrl = 'http://localhost:3000';

void main() {
  bootstrap(() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) {
            return AuthRepositoryImpl(
              initalValue: null,
              authApi: AuthApi(baseUrl: baseUrl),
            );
          },
        ),
        RepositoryProvider<DevicesRepository>(
          create:
              (context) => DevicesRepositoryImpl(
                initalValue: null,
                devicesApi: DevicesApi(baseUrl: baseUrl),
              ),
        ),
        RepositoryProvider<LogsRepository>(
          create: (context) => LogsRepositoryImpl(logsApi: LogsApi(baseUrl: baseUrl)),
        ),
      ],
      child: const App(),
    );
  });
}
