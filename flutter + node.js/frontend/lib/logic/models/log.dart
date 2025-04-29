class Log {
  final String deviceId;
  final String name;
  final String type;
  final String? errorMessage;
  final DateTime? lastAttemptAt;

  Log({
    required this.deviceId,
    required this.name,
    required this.type,
    this.errorMessage,
    this.lastAttemptAt,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      deviceId: json['device_id'],
      name: json['name'],
      type: json['type'],
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
      'error_message': errorMessage,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
    };
  }
}
