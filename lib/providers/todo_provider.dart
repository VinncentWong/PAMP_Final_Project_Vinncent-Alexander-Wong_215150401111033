import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('tasks');

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final tasksMap = Map<String, dynamic>.from(snapshot.value as Map);
      return tasksMap.entries.map((entry) {
        return {'id': entry.key, 'title': entry.value['title']};
      }).toList();
    }
    return [];
  }

  Future<void> addTask(String title) async {
    final newTaskRef = _dbRef.push();
    await newTaskRef.set({'title': title});
    notifyListeners();
  }

  Future<void> updateTask(String id, String updatedTitle) async {
    final taskRef = _dbRef.child(id);
    await taskRef.update({'title': updatedTitle});
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    final taskRef = _dbRef.child(id);
    await taskRef.remove();
    notifyListeners();
  }
}
