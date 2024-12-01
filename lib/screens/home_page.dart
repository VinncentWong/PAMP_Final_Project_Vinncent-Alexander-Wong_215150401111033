import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: todoProvider.fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];
          return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final dueDate = DateTime.parse(task['dueDate']);
                final daysLeft = dueDate.difference(DateTime.now()).inDays;

                return ListTile(
                  leading: Checkbox(
                    value: task['isCompleted'],
                    onChanged: (bool? value) {
                      todoProvider.toggleTaskCompletion(
                        task['id'],
                        value ?? false,
                      );
                    },
                  ),
                  title: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      decoration: task['isCompleted']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task['isCompleted'] ? Colors.grey : Colors.black,
                    ),
                    child: Text(task['title']),
                  ),
                  subtitle: Text(
                    'Due in $daysLeft days',
                    style: TextStyle(
                      color: daysLeft < 3 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(context, task['id'], task['title']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Provider.of<TodoProvider>(context, listen: false)
                              .deleteTask(task['id']);
                        },
                      ),
                    ],
                  ),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'Enter task title'),
                  ),
                  SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? 'Pick Due Date'
                          : 'Due Date: ${selectedDate!.toLocal()}'
                              .split(' ')[0],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String taskTitle = controller.text;
                    if (taskTitle.isNotEmpty && selectedDate != null) {
                      Provider.of<TodoProvider>(context, listen: false)
                          .addTask(taskTitle, selectedDate!);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String id, String currentTitle) {
    TextEditingController controller =
        TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter updated task name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String updatedTitle = controller.text;
                if (updatedTitle.isNotEmpty) {
                  Provider.of<TodoProvider>(context, listen: false)
                      .updateTask(id, updatedTitle);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
