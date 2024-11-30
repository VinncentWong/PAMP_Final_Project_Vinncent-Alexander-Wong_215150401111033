import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth_provider.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('tasks');
  final AuthProvider authProvider;

  TodoProvider(this.authProvider);

  String? get userId => authProvider.currentUser?.uid;

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    if (userId == null) return [];
    final snapshot = await _dbRef.child(userId!).get();
    if (snapshot.exists) {
      final tasksMap = Map<String, dynamic>.from(snapshot.value as Map);
      return tasksMap.entries.map((entry) {
        return {'id': entry.key, 'title': entry.value['title']};
      }).toList();
    }
    return [];
  }

  Future<void> addTask(String title) async {
    if (userId == null) return;
    final newTaskRef = _dbRef.child(userId!).push();
    await newTaskRef.set({'title': title});
    notifyListeners();
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
}
