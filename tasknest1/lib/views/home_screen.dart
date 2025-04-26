import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'widgets/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = GetStorage();
  final tasks = <Map<String, dynamic>>[].obs; // Now each task is a Map

  @override
  void initState() {
    super.initState();
    List<dynamic>? savedTasks = box.read('tasks');
    if (savedTasks != null) {
      tasks.assignAll(List<Map<String, dynamic>>.from(savedTasks));
    }
  }

  void _navigateToAddTask() async {
    final result = await Get.toNamed('/add_task');
    if (result != null && result is Map<String, dynamic>) {
      tasks.add(result);
      box.write('tasks', tasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (tasks.isEmpty) {
          return const Center(
            child: Text('No tasks added yet.', style: TextStyle(fontSize: 18)),
          );
        }
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () => Get.toNamed('/task_detail', arguments: task),
                title: Text(task['title'] ?? ''),
                subtitle: Text(
                  'Start: ${_formatDate(task['startDate'])}\nDeadline: ${_formatDate(task['deadline'])}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: BottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
  }
}
