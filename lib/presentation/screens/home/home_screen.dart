import 'package:flutter/material.dart';
import 'package:flutter_projects/presentation/screens/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/task_provider.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import 'add_edit_task_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskStreamProvider);
    final priority = ref.watch(priorityFilterProvider);
    final status = ref.watch(statusFilterProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddEditTaskScreen(isEdit: false),
          ),
        ),
        backgroundColor: const Color(0xFF6A5AE0),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(ref: ref),

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
        child: Column(
          children: [
            SizedBox(height: size.height * 0.12),
            _FilterBar(ref: ref),
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: tasksAsync.when(
                  data: (tasks) {
                    // apply filters
                    var filtered = tasks;
                    if (priority != 'all') {
                      filtered = filtered
                          .where((t) => t.priority == priority)
                          .toList();
                    }
                    if (status != 'all') {
                      final done = status == 'completed';
                      filtered = filtered
                          .where((t) => t.isCompleted == done)
                          .toList();
                    }

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tasks found 😴',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }

                    // group by date
                    final today = DateTime.now();
                    final tomorrow = today.add(const Duration(days: 1));
                    final weekEnd = today.add(const Duration(days: 7));

                    final todayTasks = filtered
                        .where((t) => _isSameDay(t.dueDate, today))
                        .toList();
                    final tomorrowTasks = filtered
                        .where((t) => _isSameDay(t.dueDate, tomorrow))
                        .toList();
                    final weekTasks = filtered
                        .where(
                          (t) =>
                              t.dueDate.isAfter(tomorrow) &&
                              t.dueDate.isBefore(weekEnd),
                        )
                        .toList();

                    return ListView(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 20,
                        bottom: 80,
                      ),
                      children: [
                        if (todayTasks.isNotEmpty)
                          _buildSection("Today", todayTasks),
                        if (tomorrowTasks.isNotEmpty)
                          _buildSection("Tomorrow", tomorrowTasks),
                        if (weekTasks.isNotEmpty)
                          _buildSection("This Week", weekTasks),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6A5AE0)),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      e.toString(),
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  Widget _buildSection(String title, List<TaskModel> tasks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A5AE0),
            ),
          ),
          const SizedBox(height: 10),
          ...tasks.map((task) => TaskTile(task: task)).toList(),
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
    final size = MediaQuery.of(context).size;
    final selectedPriority = ref.watch(priorityFilterProvider);
    final selectedStatus = ref.watch(statusFilterProvider);

    final priorities = ['all', 'low', 'medium', 'high'];
    final statuses = ['all', 'completed', 'pending'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Tasks',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: size.width * 0.045,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: priorities
                .map(
                  (p) => ChoiceChip(
                    label: Text(
                      p[0].toUpperCase() + p.substring(1),
                      style: const TextStyle(color: Colors.black),
                    ),
                    selected: selectedPriority == p,
                    backgroundColor: Colors.white,
                    selectedColor: Colors.lightGreen.shade100,
                    onSelected: (_) =>
                        ref.read(priorityFilterProvider.notifier).state = p,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: statuses
                .map(
                  (s) => ChoiceChip(
                    label: Text(
                      s[0].toUpperCase() + s.substring(1),
                      style: const TextStyle(color: Colors.black),
                    ),
                    selected: selectedStatus == s,
                    backgroundColor: Colors.white24,
                    selectedColor: Colors.lightGreen.shade100,
                    onSelected: (_) =>
                        ref.read(statusFilterProvider.notifier).state = s,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final WidgetRef ref;
  const _BottomNavBar({required this.ref});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: BottomAppBar(
        elevation: 10,
        color: Colors.transparent,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Colors.black,
                    size: 30,
                  ),
                  tooltip: "Menu",
                  onPressed: () => _showLeftMenu(context),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                  tooltip: "View Calendar",
                  onPressed: () => _showTaskCalendar(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLeftMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A5AE0), Color(0xFF8F8CEB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.white,
                  ),
                  title: const Text(
                    "Delete All Tasks",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text('Delete All Tasks?'),
                        content: const Text(
                          'This will permanently delete all your tasks.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: const Text('Delete All'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final user = FirebaseAuth
                          .instance
                          .currentUser; 
                      if (user != null) {
                        await TaskRepository().deleteAllTasks(
                          user.uid,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All your tasks were deleted'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User not logged in')),
                        );
                      }
                    }
                  },
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTaskCalendar(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskStreamProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: tasksAsync.when(
            data: (tasks) {
              Map<DateTime, List<TaskModel>> taskMap = {};
              for (var task in tasks) {
                final date = DateTime(
                  task.dueDate.year,
                  task.dueDate.month,
                  task.dueDate.day,
                );
                taskMap[date] = taskMap[date] ?? [];
                taskMap[date]!.add(task);
              }

              DateTime focusedDay = DateTime.now();
              DateTime? selectedDay;

              return StatefulBuilder(
                builder: (context, setState) {
                  List<TaskModel> selectedTasks = [];
                  if (selectedDay != null) {
                    final keyDate = DateTime(
                      selectedDay!.year,
                      selectedDay!.month,
                      selectedDay!.day,
                    );
                    selectedTasks = taskMap[keyDate] ?? [];
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "📅 Task Calendar",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A5AE0),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TableCalendar(
                        focusedDay: focusedDay,
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2100, 1, 1),
                        calendarFormat: CalendarFormat.month,
                        selectedDayPredicate: (day) =>
                            selectedDay != null &&
                            _isSameDay(day, selectedDay!),
                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                        ),
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF6A5AE0),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        eventLoader: (day) {
                          final date = DateTime(day.year, day.month, day.day);
                          return taskMap[date] ?? [];
                        },
                        onDaySelected: (selected, focused) {
                          setState(() {
                            selectedDay = selected;
                            focusedDay = focused;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      if (selectedDay != null)
                        selectedTasks.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tasks on ${DateFormat('d MMM, yyyy').format(selectedDay!)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6A5AE0),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...selectedTasks.map(
                                    (t) => Card(
                                      color: Colors.grey.shade100,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          t.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          t.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  "No tasks on ${DateFormat('d MMM').format(selectedDay!)} 🎉",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                    ],
                  );
                },
              );
            },
            loading: () => const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Center(
              child: Text(
                e.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}
