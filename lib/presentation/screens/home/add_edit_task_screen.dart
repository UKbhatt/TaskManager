import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';

class AddEditTaskScreen extends StatefulWidget {
  final bool isEdit;
  final TaskModel? task;
  const AddEditTaskScreen({super.key, required this.isEdit, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now();
  String _priority = 'low';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.task != null) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final repo = TaskRepository();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final task = TaskModel(
      id: widget.isEdit ? widget.task!.id : '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      isCompleted: widget.task?.isCompleted ?? false,
    );

    try {
      if (widget.isEdit) {
        await repo.updateTask(task.id, task.toMap());
      } else {
        await repo.addTask(task, uid);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.isEdit ? 'Edit Task' : 'Add Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8F8CEB), Color(0xFF6A5AE0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.12,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.04,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.title, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon:
                        const Icon(Icons.description_outlined, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.indigo.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.indigo),
                    title: const Text(
                      'Due Date',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _dueDate.toLocal().toString().split(' ')[0],
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_calendar_rounded,
                          color: Colors.indigo),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _dueDate = date);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: _priority,
                  onChanged: (v) => setState(() => _priority = v ?? 'low'),
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    prefixIcon:
                        const Icon(Icons.flag_rounded, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'low',
                        child: Text('Low', style: TextStyle(color: Colors.green))),
                    DropdownMenuItem(
                        value: 'medium',
                        child: Text('Medium', style: TextStyle(color: Colors.orange))),
                    DropdownMenuItem(
                        value: 'high',
                        child: Text('High', style: TextStyle(color: Colors.red))),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _save,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text(
                      _loading
                          ? 'Saving...'
                          : widget.isEdit
                              ? 'Update Task'
                              : 'Add Task',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
