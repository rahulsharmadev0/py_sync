enum SyncStatusCode {
  success(200),
  badRequest(400),
  notFound(404),
  serverError(500),
  syncing(-1),
  unknown(0);

  final int code;

  const SyncStatusCode(this.code);

  factory SyncStatusCode.fromCode(int? code) {
    return SyncStatusCode.values.firstWhere(
      (status) => status.code == code,
      orElse: () => SyncStatusCode.unknown,
    );
  }
}

class Device {
  final String deviceId;
  final String name;
  final SyncStatusCode syncStatusCode;
  final String? type;
  final DateTime? lastSyncAt;
  final String? errorMessage;
  final DateTime? lastAttemptAt;

  Device({
    required this.deviceId,
    required this.name,
    required this.type,
    this.lastSyncAt,
    this.syncStatusCode = SyncStatusCode.unknown,
    this.errorMessage,
    this.lastAttemptAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      name: json['name'],
      type: json['type'],
      lastSyncAt:
          json['last_sync_at'] != null ? DateTime.parse(json['last_sync_at']) : null,
      syncStatusCode: SyncStatusCode.fromCode(json['sync_status_code']),
      errorMessage: json['error_message'],
      lastAttemptAt:
          json['last_attempt_at'] != null
              ? DateTime.parse(json['last_attempt_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'name': name,
      'type': type,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'sync_status_code': syncStatusCode.code,
      'error_message': errorMessage,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
    };
  }

  Device copyWith({
    String? deviceId,
    String? name,
    SyncStatusCode? syncStatusCode,
    String? type,
    DateTime? lastSyncAt,
    String? errorMessage,
    DateTime? lastAttemptAt,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      type: type ?? this.type,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncStatusCode: syncStatusCode ?? this.syncStatusCode,
      errorMessage: errorMessage ?? this.errorMessage,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }
}
