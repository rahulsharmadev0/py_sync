import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:py_sync/logic/models/log.dart';
import 'package:py_sync/logic/repositories/logs_repository.dart';

sealed class LogsEvent {
  const LogsEvent();
}

class RefreshLogsEvent extends LogsEvent {}

class LoadPageEvent extends LogsEvent {
  final int page;
  final int? limit;
  final String? sortBy;
  final String? order;

  LoadPageEvent(this.page, {this.limit, this.sortBy, this.order});
}

enum LogStatus { idle, loading, loaded, error }

class LogState {
  final LogStatus status;
  final List<Log> logs;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final String? errorMessage;

  LogState({
    required this.status,
    required this.logs,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    this.errorMessage,
  });

  factory LogState.initial() {
    return LogState(
      status: LogStatus.idle,
      logs: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
      itemsPerPage: 10,
    );
  }

  LogState copyWith({
    LogStatus? status,
    List<Log>? logs,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    int? itemsPerPage,
    String? errorMessage,
  }) {
    return LogState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ErrorLogsBloc extends Bloc<LogsEvent, LogState> {
  final LogsRepository logsRepository;

  ErrorLogsBloc(this.logsRepository) : super(LogState.initial()) {
    on<RefreshLogsEvent>(_handleRefreshLogs);
    on<LoadPageEvent>(_handleLoadPage);
  }

  /// Handles the refresh logs event by fetching logs with pagination (first page)
  Future<void> _handleRefreshLogs(RefreshLogsEvent event, Emitter<LogState> emit) async {
    // Skip if already loading
    if (state.status == LogStatus.loading) return;

    emit(state.copyWith(status: LogStatus.loading));

    try {
      final response = await logsRepository.getAllLogs(
        page: 1,
        limit: state.itemsPerPage,
        sortBy: 'last_attempt_at',
        order: 'desc',
      );

      emit(
        state.copyWith(
          status: LogStatus.loaded,
          logs: response.logs,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          totalItems: response.totalItems,
          itemsPerPage: response.limit,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: LogStatus.error, errorMessage: 'Failed to fetch logs: $e'),
      );
    }
  }

  /// Handles loading a specific page of logs
  Future<void> _handleLoadPage(LoadPageEvent event, Emitter<LogState> emit) async {
    // Skip if already loading
    if (state.status == LogStatus.loading) return;

    emit(state.copyWith(status: LogStatus.loading));

    try {
      final response = await logsRepository.getAllLogs(
        page: event.page,
        limit: event.limit ?? state.itemsPerPage,
        sortBy: event.sortBy ?? 'last_attempt_at',
        order: event.order ?? 'desc',
      );

      emit(
        state.copyWith(
          status: LogStatus.loaded,
          logs: response.logs,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          totalItems: response.totalItems,
          itemsPerPage: response.limit,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: LogStatus.error, errorMessage: 'Failed to fetch logs: $e'),
      );
    }
  }
}
