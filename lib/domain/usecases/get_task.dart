import '../../data/repositories/task_repository.dart';
import '../../data/models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetTasks {
  final TaskRepository repo;
  GetTasks(this.repo);

  Stream<List<TaskModel>> call() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return repo.getTasks(uid);
  }
}
