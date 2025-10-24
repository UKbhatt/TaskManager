import '../../data/repositories/task_repository.dart';

class UpdateTask {
  final TaskRepository repo;
  UpdateTask(this.repo);

  Future<void> call(String id, Map<String, dynamic> data) async {
    await repo.updateTask(id, data);
  }
}
