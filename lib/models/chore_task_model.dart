import 'dart:convert';

class ChoreTaskModel {
  final String id;
  final String childId;
  final String title;
  final String description;
  final int rewardMinutes;
  final bool isCompletedByKid;
  final bool isApprovedByParent;
  final String iconEmoji;
  final DateTime createdAt;
  final String? proofNote;

  ChoreTaskModel({
    required this.id,
    required this.childId,
    required this.title,
    this.description = '',
    required this.rewardMinutes,
    this.isCompletedByKid = false,
    this.isApprovedByParent = false,
    this.iconEmoji = '⭐',
    DateTime? createdAt,
    this.proofNote,
  }) : createdAt = createdAt ?? DateTime.now();

  ChoreTaskModel copyWith({
    String? id,
    String? childId,
    String? title,
    String? description,
    int? rewardMinutes,
    bool? isCompletedByKid,
    bool? isApprovedByParent,
    String? iconEmoji,
    DateTime? createdAt,
    String? proofNote,
  }) {
    return ChoreTaskModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardMinutes: rewardMinutes ?? this.rewardMinutes,
      isCompletedByKid: isCompletedByKid ?? this.isCompletedByKid,
      isApprovedByParent: isApprovedByParent ?? this.isApprovedByParent,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      createdAt: createdAt ?? this.createdAt,
      proofNote: proofNote ?? this.proofNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'description': description,
      'rewardMinutes': rewardMinutes,
      'isCompletedByKid': isCompletedByKid,
      'isApprovedByParent': isApprovedByParent,
      'iconEmoji': iconEmoji,
      'createdAt': createdAt.toIso8601String(),
      'proofNote': proofNote,
    };
  }

  factory ChoreTaskModel.fromMap(Map<String, dynamic> map) {
    return ChoreTaskModel(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      rewardMinutes: map['rewardMinutes']?.toInt() ?? 15,
      isCompletedByKid: map['isCompletedByKid'] ?? false,
      isApprovedByParent: map['isApprovedByParent'] ?? false,
      iconEmoji: map['iconEmoji'] ?? '⭐',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      proofNote: map['proofNote'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ChoreTaskModel.fromJson(String source) => ChoreTaskModel.fromMap(json.decode(source));
}
