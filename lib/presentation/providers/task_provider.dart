import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

final taskRepoProvider = Provider((ref) => TaskRepository());

final taskStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return ref.watch(taskRepoProvider).getTasks(user.uid);
});

final priorityFilterProvider = StateProvider<String>((ref) => 'all');
final statusFilterProvider = StateProvider<String>((ref) => 'all');
