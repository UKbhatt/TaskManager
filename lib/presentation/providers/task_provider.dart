import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

final taskRepoProvider = Provider<TaskRepository>((ref) => TaskRepository());

final taskStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final authChanges = FirebaseAuth.instance.authStateChanges();
  final repo = ref.watch(taskRepoProvider);

  return authChanges.switchMap((user) {
    if (user == null) {
      return const Stream<List<TaskModel>>.empty();
    }
    return repo.getTasks(user.uid);
  });
});

final priorityFilterProvider = StateProvider<String>((ref) => 'all');
final statusFilterProvider = StateProvider<String>((ref) => 'all');
