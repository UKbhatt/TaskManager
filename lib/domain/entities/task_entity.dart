class TaskEntity {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; 
  final bool isCompleted;

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });
}
