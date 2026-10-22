import 'dart:convert';

class AppRuleModel {
  final String id;
  final String childId;
  final String appName;
  final String packageOrUrl;
  final String category;
  final String iconEmoji;
  final bool isBlocked;
  final int dailyLimitMinutes;
  final int usedMinutesToday;
  final bool isEnabled;
  final bool isGlobalRule;

  AppRuleModel({
    required this.id,
    required this.childId,
    required this.appName,
    required this.packageOrUrl,
    required this.category,
    this.iconEmoji = '📱',
    this.isBlocked = false,
    this.dailyLimitMinutes = 60,
    this.usedMinutesToday = 20,
    this.isEnabled = true,
    this.isGlobalRule = false,
  });

  AppRuleModel copyWith({
    String? id,
    String? childId,
    String? appName,
    String? packageOrUrl,
    String? category,
    String? iconEmoji,
    bool? isBlocked,
    int? dailyLimitMinutes,
    int? usedMinutesToday,
    bool? isEnabled,
    bool? isGlobalRule,
  }) {
    return AppRuleModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      appName: appName ?? this.appName,
      packageOrUrl: packageOrUrl ?? this.packageOrUrl,
      category: category ?? this.category,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isBlocked: isBlocked ?? this.isBlocked,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      usedMinutesToday: usedMinutesToday ?? this.usedMinutesToday,
      isEnabled: isEnabled ?? this.isEnabled,
      isGlobalRule: isGlobalRule ?? this.isGlobalRule,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'appName': appName,
      'packageOrUrl': packageOrUrl,
      'category': category,
      'iconEmoji': iconEmoji,
      'isBlocked': isBlocked,
      'dailyLimitMinutes': dailyLimitMinutes,
      'usedMinutesToday': usedMinutesToday,
      'isEnabled': isEnabled,
      'isGlobalRule': isGlobalRule,
    };
  }

  factory AppRuleModel.fromMap(Map<String, dynamic> map) {
    return AppRuleModel(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      appName: map['appName'] ?? '',
      packageOrUrl: map['packageOrUrl'] ?? '',
      category: map['category'] ?? 'Ứng dụng',
      iconEmoji: map['iconEmoji'] ?? '📱',
      isBlocked: map['isBlocked'] ?? false,
      dailyLimitMinutes: map['dailyLimitMinutes']?.toInt() ?? 60,
      usedMinutesToday: map['usedMinutesToday']?.toInt() ?? 0,
      isEnabled: map['isEnabled'] ?? true,
      isGlobalRule: map['isGlobalRule'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppRuleModel.fromJson(String source) => AppRuleModel.fromMap(json.decode(source));
}
