import 'dart:async';
import 'package:py_sync/logic/apis/logs_api.dart';
import 'package:py_sync/logic/models/log.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';
import 'package:py_sync/logic/repositories/logs_repository.dart';

class LogsRepositoryImpl extends LogsRepository {
  final LogsApi logsApi;

  LogsRepositoryImpl({required this.logsApi});

  @override
  FutureOr<PaginatedLogsResponse> getAllLogs({
    int page = 1,
    int limit = 10,
    String? sortBy = 'last_attempt_at',
    String? order = 'desc',
  }) async {
    var jwtToken = AuthRepository.currentUser?.jwtToken;
    if (jwtToken == null) {
      throw Exception('User is not logged in');
    }

    return handleErrorsAndRetry(() async {
      final response = await logsApi.getAllLogs(
        jwtToken,
        page: page,
        limit: limit,
        sortBy: sortBy,
        order: order,
      );

      // Parse logs from 'data' field as shown in the backend API
      final logs = (response['data'] as List).map((item) => Log.fromJson(item)).toList();

      return PaginatedLogsResponse(
        logs: logs,
        currentPage: response['page'] ?? 1,
        totalPages: response['totalPages'] ?? 1,
        totalItems: response['totalItems'] ?? logs.length,
        limit: response['limit'] ?? limit,
      );
    }, errorPrefix: 'Failed to fetch logs');
  }
}
