import 'dart:convert';

enum TicketStatus {
  pending,
  inProgress,
  resolved,
}

extension TicketStatusExtension on TicketStatus {
  String get displayName {
    switch (this) {
      case TicketStatus.pending:
        return 'Chờ tiếp nhận';
      case TicketStatus.inProgress:
        return 'Đang xử lý';
      case TicketStatus.resolved:
        return 'Đã giải quyết';
    }
  }
}

class SupportTicketModel {
  final String id;
  final String parentId;
  final String parentName;
  final String title;
  final String content;
  final String priority; // Thấp, Trung bình, Khẩn cấp
  final TicketStatus status;
  final DateTime createdAt;
  final String? staffResponse;
  final String? staffName;

  SupportTicketModel({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.title,
    required this.content,
    this.priority = 'Trung bình',
    this.status = TicketStatus.pending,
    DateTime? createdAt,
    this.staffResponse,
    this.staffName,
  }) : createdAt = createdAt ?? DateTime.now();

  SupportTicketModel copyWith({
    String? id,
    String? parentId,
    String? parentName,
    String? title,
    String? content,
    String? priority,
    TicketStatus? status,
    DateTime? createdAt,
    String? staffResponse,
    String? staffName,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      staffResponse: staffResponse ?? this.staffResponse,
      staffName: staffName ?? this.staffName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'parentName': parentName,
      'title': title,
      'content': content,
      'priority': priority,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'staffResponse': staffResponse,
      'staffName': staffName,
    };
  }

  factory SupportTicketModel.fromMap(Map<String, dynamic> map) {
    return SupportTicketModel(
      id: map['id'] ?? '',
      parentId: map['parentId'] ?? '',
      parentName: map['parentName'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      priority: map['priority'] ?? 'Trung bình',
      status: TicketStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TicketStatus.pending,
      ),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      staffResponse: map['staffResponse'],
      staffName: map['staffName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SupportTicketModel.fromJson(String source) => SupportTicketModel.fromMap(json.decode(source));
}
