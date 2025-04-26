class Task {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime deadline;
  final DateTime nextReminder;
  final String reminderNotes;
  final String status;
  final String remarks;

  Task({
    required this.title,
    required this.description,
    required this.startDate,
    required this.deadline,
    required this.nextReminder,
    this.reminderNotes = '',
    required this.status,
    this.remarks = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'nextReminder': nextReminder.toIso8601String(),
      'reminderNotes': reminderNotes,
      'status': status,
      'remarks': remarks,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      deadline: DateTime.parse(json['deadline']),
      nextReminder: DateTime.parse(json['nextReminder']),
      reminderNotes: json['reminderNotes'] ?? '',
      status: json['status'],
      remarks: json['remarks'] ?? '',
    );
  }
}