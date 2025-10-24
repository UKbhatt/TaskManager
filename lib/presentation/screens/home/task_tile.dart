import 'package:flutter/material.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import 'add_edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  const TaskTile({super.key, required this.task});

  // 🔹 Priority-based gradient background
  LinearGradient _priorityGradient(String p) {
    switch (p) {
      case 'high':
        return const LinearGradient(
          colors: [Color(0xFFFF9A9E), Color(0xFFF6416C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'medium':
        return const LinearGradient(
          colors: [Color(0xFFFFE57F), Color(0xFFFFA726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFA8E063), Color(0xFF56AB2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository();
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.008,
      ),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.8),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_forever,
              color: Colors.white, size: 30),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Delete Task?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                  'Are you sure you want to delete this task permanently?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) async {
          await repo.deleteTask(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted successfully')),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: _priorityGradient(task.priority),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditTaskScreen(isEdit: true, task: task),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.015,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ Checkbox animation
                  GestureDetector(
                    onTap: () async {
                      await repo.updateTask(task.id, {
                        'isCompleted': !task.isCompleted,
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: size.width * 0.06,
                      width: size.width * 0.06,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? Colors.white
                            : Colors.transparent,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.black)
                          : null,
                    ),
                  ),
                  SizedBox(width: size.width * 0.04),

                  // 📝 Task Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                            color: Colors.white,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: size.width * 0.035,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              "Due: ${task.dueDate.toLocal().toString().split(' ')[0]}",
                              style: TextStyle(
                                fontSize: size.width * 0.032,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ✏️ Edit Button
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditTaskScreen(isEdit: true, task: task),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
