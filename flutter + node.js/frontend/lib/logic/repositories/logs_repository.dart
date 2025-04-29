import 'dart:async';

import 'package:py_sync/logic/models/log.dart';
import 'package:py_sync/logic/utils/repository_utils.dart';

class PaginatedLogsResponse {
  final List<Log> logs;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;

  PaginatedLogsResponse({
    required this.logs,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
  });
}

abstract class LogsRepository with ErrorHandlingAndRetryMixin {
  // Get all logs with pagination support
  FutureOr<PaginatedLogsResponse> getAllLogs({
    int page = 1,
    int limit = 10,
    String? sortBy = 'last_attempt_at',
    String? order = 'desc',
  });
}
