import 'package:flutter/material.dart';

enum TaskStatus {
  todo('To-Do'),
  inProgress('In Progress'),
  done('Done');

  final String label;
  const TaskStatus(this.label);

  static TaskStatus fromString(String status) {
    return TaskStatus.values.firstWhere((e) => e.label == status);
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return Colors.red.shade400;
      case TaskStatus.inProgress:
        return Colors.orange.shade400;
      case TaskStatus.done:
        return Colors.green.shade400;
    }
  }
}

class Task {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final int? blockedById;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['due_date']),
      status: TaskStatus.fromString(json['status']),
      blockedById: json['blocked_by_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'status': status.label,
      'blocked_by_id': blockedById,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    int? blockedById,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: blockedById ?? this.blockedById,
    );
  }
}
