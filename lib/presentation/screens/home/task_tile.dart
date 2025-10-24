import 'package:flutter/material.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import 'add_edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  const TaskTile({super.key, required this.task});

  Color _priorityColor(String p) {
    switch (p) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (v) =>
              repo.updateTask(task.id, {'isCompleted': v ?? false}),
        ),
        title: Text(
          task.title,
          style: TextStyle(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null),
        ),
        subtitle: Text(
          '${task.description}\nDue: ${task.dueDate.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: _priorityColor(task.priority), size: 12),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.indigo),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddEditTaskScreen(isEdit: true, task: task))),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => repo.deleteTask(task.id),
            ),
          ],
        ),
      ),
    );
  }
}
