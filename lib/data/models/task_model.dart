import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dueDate,
    required super.priority,
    required super.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      priority: data['priority'] ?? 'low',
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}
