import 'dart:convert';

class SafeZoneModel {
  final String id;
  final String childId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool alertOnExit;
  final bool alertOnEnter;
  final String iconEmoji;
  final bool isEnabled;

  SafeZoneModel({
    required this.id,
    required this.childId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 300.0,
    this.alertOnExit = true,
    this.alertOnEnter = true,
    this.iconEmoji = '🏫',
    this.isEnabled = true,
  });

  SafeZoneModel copyWith({
    String? id,
    String? childId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? alertOnExit,
    bool? alertOnEnter,
    String? iconEmoji,
    bool? isEnabled,
  }) {
    return SafeZoneModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      alertOnExit: alertOnExit ?? this.alertOnExit,
      alertOnEnter: alertOnEnter ?? this.alertOnEnter,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'alertOnExit': alertOnExit,
      'alertOnEnter': alertOnEnter,
      'iconEmoji': iconEmoji,
      'isEnabled': isEnabled,
    };
  }

  factory SafeZoneModel.fromMap(Map<String, dynamic> map) {
    return SafeZoneModel(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 10.7769,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 106.7009,
      radiusMeters: (map['radiusMeters'] as num?)?.toDouble() ?? 300.0,
      alertOnExit: map['alertOnExit'] ?? true,
      alertOnEnter: map['alertOnEnter'] ?? true,
      iconEmoji: map['iconEmoji'] ?? '🏫',
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory SafeZoneModel.fromJson(String source) => SafeZoneModel.fromMap(json.decode(source));
}
