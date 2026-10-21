import 'dart:convert';

class ChildDeviceModel {
  final String id;
  final String parentId;
  final String name;
  final int age;
  final String gender;
  final String avatar;
  final String deviceName;
  final int batteryLevel;
  final bool isOnline;
  final bool isLocked;
  final double latitude;
  final double longitude;
  final String currentAddress;
  final DateTime lastSeen;
  final String pairingCode;
  final int screenTimeUsedMinutes;
  final int screenTimeLimitMinutes;
  final double currentNoiseDb;
  final bool isMotionAlert;
  final bool isSosActive;

  ChildDeviceModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.gender,
    required this.avatar,
    required this.deviceName,
    this.batteryLevel = 85,
    this.isOnline = true,
    this.isLocked = false,
    this.latitude = 10.7769, // Mặc định TP. Hồ Chí Minh
    this.longitude = 106.7009,
    this.currentAddress = 'Trường Tiểu học Nguyễn Huệ, Quận 1',
    DateTime? lastSeen,
    required this.pairingCode,
    this.screenTimeUsedMinutes = 45,
    this.screenTimeLimitMinutes = 120,
    this.currentNoiseDb = 42.0,
    this.isMotionAlert = false,
    this.isSosActive = false,
  }) : lastSeen = lastSeen ?? DateTime.now();

  ChildDeviceModel copyWith({
    String? id,
    String? parentId,
    String? name,
    int? age,
    String? gender,
    String? avatar,
    String? deviceName,
    int? batteryLevel,
    bool? isOnline,
    bool? isLocked,
    double? latitude,
    double? longitude,
    String? currentAddress,
    DateTime? lastSeen,
    String? pairingCode,
    int? screenTimeUsedMinutes,
    int? screenTimeLimitMinutes,
    double? currentNoiseDb,
    bool? isMotionAlert,
    bool? isSosActive,
  }) {
    return ChildDeviceModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      deviceName: deviceName ?? this.deviceName,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isOnline: isOnline ?? this.isOnline,
      isLocked: isLocked ?? this.isLocked,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      currentAddress: currentAddress ?? this.currentAddress,
      lastSeen: lastSeen ?? this.lastSeen,
      pairingCode: pairingCode ?? this.pairingCode,
      screenTimeUsedMinutes: screenTimeUsedMinutes ?? this.screenTimeUsedMinutes,
      screenTimeLimitMinutes: screenTimeLimitMinutes ?? this.screenTimeLimitMinutes,
      currentNoiseDb: currentNoiseDb ?? this.currentNoiseDb,
      isMotionAlert: isMotionAlert ?? this.isMotionAlert,
      isSosActive: isSosActive ?? this.isSosActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'name': name,
      'age': age,
      'gender': gender,
      'avatar': avatar,
      'deviceName': deviceName,
      'batteryLevel': batteryLevel,
      'isOnline': isOnline,
      'isLocked': isLocked,
      'latitude': latitude,
      'longitude': longitude,
      'currentAddress': currentAddress,
      'lastSeen': lastSeen.toIso8601String(),
      'pairingCode': pairingCode,
      'screenTimeUsedMinutes': screenTimeUsedMinutes,
      'screenTimeLimitMinutes': screenTimeLimitMinutes,
      'currentNoiseDb': currentNoiseDb,
      'isMotionAlert': isMotionAlert,
      'isSosActive': isSosActive,
    };
  }

  factory ChildDeviceModel.fromMap(Map<String, dynamic> map) {
    return ChildDeviceModel(
      id: map['id'] ?? '',
      parentId: map['parentId'] ?? '',
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 10,
      gender: map['gender'] ?? 'Nam',
      avatar: map['avatar'] ?? '👦',
      deviceName: map['deviceName'] ?? 'Điện thoại của bé',
      batteryLevel: map['batteryLevel']?.toInt() ?? 80,
      isOnline: map['isOnline'] ?? true,
      isLocked: map['isLocked'] ?? false,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 10.7769,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 106.7009,
      currentAddress: map['currentAddress'] ?? '',
      lastSeen: map['lastSeen'] != null ? DateTime.parse(map['lastSeen']) : DateTime.now(),
      pairingCode: map['pairingCode'] ?? 'KID123',
      screenTimeUsedMinutes: map['screenTimeUsedMinutes']?.toInt() ?? 0,
      screenTimeLimitMinutes: map['screenTimeLimitMinutes']?.toInt() ?? 120,
      currentNoiseDb: (map['currentNoiseDb'] as num?)?.toDouble() ?? 40.0,
      isMotionAlert: map['isMotionAlert'] ?? false,
      isSosActive: map['isSosActive'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChildDeviceModel.fromJson(String source) => ChildDeviceModel.fromMap(json.decode(source));
}
