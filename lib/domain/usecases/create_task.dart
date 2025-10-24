import '../../data/repositories/task_repository.dart';
import '../../data/models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTask {
  final TaskRepository repo;
  CreateTask(this.repo);

  Future<void> call(TaskModel task) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not logged in');
    await repo.addTask(task, uid);
  }
}
