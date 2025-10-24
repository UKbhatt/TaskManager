import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../providers/task_provider.dart';
import '../auth/login_screen.dart';
import 'add_edit_task_screen.dart';
import 'task_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskStreamProvider);
    final priority = ref.watch(priorityFilterProvider);
    final status = ref.watch(statusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthRepository().logout();
              if (context.mounted) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddEditTaskScreen(isEdit: false))),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _FilterBar(ref: ref),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                var filtered = tasks;
                if (priority != 'all') {
                  filtered = filtered
                      .where((t) => t.priority == priority)
                      .toList();
                }
                if (status != 'all') {
                  final done = status == 'completed';
                  filtered =
                      filtered.where((t) => t.isCompleted == done).toList();
                }
                if (filtered.isEmpty) {
                  return const Center(child: Text('No tasks found'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => TaskTile(task: filtered[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          )
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final WidgetRef ref;
  const _FilterBar({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: ref.watch(priorityFilterProvider),
            onChanged: (v) =>
                ref.read(priorityFilterProvider.notifier).state = v ?? 'all',
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'low', child: Text('Low')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'high', child: Text('High')),
            ],
          ),
          DropdownButton<String>(
            value: ref.watch(statusFilterProvider),
            onChanged: (v) =>
                ref.read(statusFilterProvider.notifier).state = v ?? 'all',
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
            ],
          ),
        ],
      ),
    );
  }
}
