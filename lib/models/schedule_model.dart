import 'dart:convert';

class ScheduleModel {
  final String id;
  final String childId;
  final String title;
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"
  final List<int> daysOfWeek; // 1 = T2, 7 = CN
  final bool isLockDevice;
  final bool isEnabled;
  final String iconEmoji;

  ScheduleModel({
    required this.id,
    required this.childId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    this.isLockDevice = true,
    this.isEnabled = true,
    this.iconEmoji = '🌙',
  });

  ScheduleModel copyWith({
    String? id,
    String? childId,
    String? title,
    String? startTime,
    String? endTime,
    List<int>? daysOfWeek,
    bool? isLockDevice,
    bool? isEnabled,
    String? iconEmoji,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isLockDevice: isLockDevice ?? this.isLockDevice,
      isEnabled: isEnabled ?? this.isEnabled,
      iconEmoji: iconEmoji ?? this.iconEmoji,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'daysOfWeek': daysOfWeek,
      'isLockDevice': isLockDevice,
      'isEnabled': isEnabled,
      'iconEmoji': iconEmoji,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      title: map['title'] ?? '',
      startTime: map['startTime'] ?? '22:00',
      endTime: map['endTime'] ?? '06:00',
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? [1, 2, 3, 4, 5, 6, 7]),
      isLockDevice: map['isLockDevice'] ?? true,
      isEnabled: map['isEnabled'] ?? true,
      iconEmoji: map['iconEmoji'] ?? '🌙',
    );
  }

  String toJson() => json.encode(toMap());

  factory ScheduleModel.fromJson(String source) => ScheduleModel.fromMap(json.decode(source));
}
