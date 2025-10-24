import '../datasources/firebase_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  final _tasks = FirebaseService.firestore.collection('tasks');

  Future<void> addTask(TaskModel task, String uid) async {
    await _tasks.add({
      ...task.toMap(),
      'userId': uid,
    });
  }

  Stream<List<TaskModel>> getTasks(String uid) {
    return _tasks
        .where('userId', isEqualTo: uid)
        .orderBy('dueDate')
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskModel.fromDoc(d)).toList());
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    await _tasks.doc(id).update(data);
  }

  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }
}
