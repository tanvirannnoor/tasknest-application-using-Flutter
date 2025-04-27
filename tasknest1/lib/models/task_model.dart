class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? deadline;
  final bool isCompleted;
  final String? category;
  final int? priority; // 1-3, where 3 is highest
  final DateTime? startDate;
  final DateTime? nextReminder;
  final String? reminderNotes;
  final String status;
  final String? remarks;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.deadline,
    this.isCompleted = false,
    this.category,
    this.priority,
    this.startDate,
    this.nextReminder,
    this.reminderNotes,
    this.status = 'Pending',
    this.remarks,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isCompleted: json['isCompleted'] ?? false,
      category: json['category'],
      priority: json['priority'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      nextReminder: json['nextReminder'] != null ? DateTime.parse(json['nextReminder']) : null,
      reminderNotes: json['reminderNotes'],
      status: json['status'] ?? 'Pending',
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
      'priority': priority,
      'startDate': startDate?.toIso8601String(),
      'nextReminder': nextReminder?.toIso8601String(),
      'reminderNotes': reminderNotes,
      'status': status,
      'remarks': remarks,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    String? category,
    int? priority,
    DateTime? startDate,
    DateTime? nextReminder,
    String? reminderNotes,
    String? status,
    String? remarks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      nextReminder: nextReminder ?? this.nextReminder,
      reminderNotes: reminderNotes ?? this.reminderNotes,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }
}