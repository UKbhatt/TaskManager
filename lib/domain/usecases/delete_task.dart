import '../../data/repositories/task_repository.dart';

class DeleteTask {
  final TaskRepository repo;
  DeleteTask(this.repo);

  Future<void> call(String id) async {
    await repo.deleteTask(id);
  }
}
