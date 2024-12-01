import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth_provider.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('tasks');
  final AuthProvider authProvider;

  TodoProvider(this.authProvider);

  String? get userId => authProvider.currentUser?.uid;

  Future<void> addTask(String title, DateTime dueDate) async {
    if (userId == null) return;
    final newTaskRef = _dbRef.child(userId!).push();

    final taskData = {
      'title': title,
      'isCompleted': false,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'dueDate': dueDate.toIso8601String(),
    };

    await newTaskRef.set(taskData);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    if (userId == null) return [];
    final snapshot = await _dbRef.child(userId!).get();
    if (snapshot.exists) {
      final tasksMap = Map<String, dynamic>.from(snapshot.value as Map);
      final tasks = tasksMap.entries.map((entry) {
        final value = Map<String, dynamic>.from(entry.value);
        return {
          'id': entry.key,
          'title': value['title'],
          'isCompleted': value['isCompleted'] ?? false,
          'timestamp': value['timestamp'] ?? 0,
          'dueDate': value['dueDate'] ?? DateTime.now().toIso8601String(),
        };
      }).toList();

      tasks.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      return tasks;
    }
    return [];
  }

  Future<void> updateTask(String id, String updatedTitle) async {
    if (userId == null) return;
    final taskRef = _dbRef.child(userId!).child(id);
    await taskRef.update({'title': updatedTitle});
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    if (userId == null) return;
    final taskRef = _dbRef.child(userId!).child(id);
    await taskRef.remove();
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    if (userId == null) return;
    final taskRef = _dbRef.child(userId!).child(id);
    await taskRef.update({'isCompleted': isCompleted});
    notifyListeners();
  }
}
