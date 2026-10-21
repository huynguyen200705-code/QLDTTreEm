import 'dart:convert';

enum LogType {
  sosAlert,
  fallDetected,
  noiseAlert,
  geofenceExit,
  geofenceEnter,
  appBlocked,
  timeLimitExceeded,
  screenLocked,
  systemInfo,
}

extension LogTypeExtension on LogType {
  String get title {
    switch (this) {
      case LogType.sosAlert:
        return '🚨 CẢNH BÁO SOS KHẨN CẤP!';
      case LogType.fallDetected:
        return '⚠️ Phát hiện va chạm / Té ngã mạnh';
      case LogType.noiseAlert:
        return '🔊 Mức tiếng ồn bất thường (>80dB)';
      case LogType.geofenceExit:
        return '📍 Đã rời khỏi vùng an toàn';
      case LogType.geofenceEnter:
        return '🏡 Đã vào vùng an toàn';
      case LogType.appBlocked:
        return '🚫 Cố gắng mở ứng dụng bị cấm';
      case LogType.timeLimitExceeded:
        return '⏳ Hết thời gian sử dụng trong ngày';
      case LogType.screenLocked:
        return '🔒 Thiết bị đã được khóa từ xa';
      case LogType.systemInfo:
        return 'ℹ️ Thông báo hệ thống';
    }
  }

  String get emoji {
    switch (this) {
      case LogType.sosAlert:
        return '🚨';
      case LogType.fallDetected:
        return '💥';
      case LogType.noiseAlert:
        return '🔊';
      case LogType.geofenceExit:
        return '🏃';
      case LogType.geofenceEnter:
        return '🏫';
      case LogType.appBlocked:
        return '🚫';
      case LogType.timeLimitExceeded:
        return '⌛';
      case LogType.screenLocked:
        return '🔒';
      case LogType.systemInfo:
        return '🔔';
    }
  }
}

class ActivityLogModel {
  final String id;
  final String childId;
  final String childName;
  final LogType type;
  final String message;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? extraData;
  final bool isRead;

  ActivityLogModel({
    required this.id,
    required this.childId,
    required this.childName,
    required this.type,
    required this.message,
    DateTime? timestamp,
    this.latitude,
    this.longitude,
    this.extraData,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  ActivityLogModel copyWith({
    String? id,
    String? childId,
    String? childName,
    LogType? type,
    String? message,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? extraData,
    bool? isRead,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      extraData: extraData ?? this.extraData,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'childName': childName,
      'type': type.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'extraData': extraData,
      'isRead': isRead,
    };
  }

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      childName: map['childName'] ?? '',
      type: LogType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => LogType.systemInfo,
      ),
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      extraData: map['extraData'],
      isRead: map['isRead'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActivityLogModel.fromJson(String source) => ActivityLogModel.fromMap(json.decode(source));
}
