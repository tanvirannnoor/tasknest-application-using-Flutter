import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'widgets/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = GetStorage();
  final tasks = <Map<String, dynamic>>[].obs;
  final selectedStatus = 'OnGoing'.obs;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy - hh:mm a');

  final List<String> _statusOptions = ['All', 'OnGoing', 'Pending', 'Done'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    try {
      List<dynamic>? savedTasks = box.read('tasks');
      if (savedTasks != null) {
        tasks.assignAll(List<Map<String, dynamic>>.from(savedTasks));
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      // Initialize with empty list if there's an error
      box.write('tasks', []);
    }
  }

  void _navigateToAddTask() async {
    final result = await Get.toNamed('/add_task');
    if (result != null && result is Map<String, dynamic>) {
      tasks.add(result);
      box.write('tasks', tasks);
    }
  }

  void _navigateToTaskDetail(Map<String, dynamic> task, int index) async {
    final result = await Get.toNamed(
      '/task_detail',
      arguments: {'task': task, 'index': index},
    );
    if (result != null) {
      if (result == 'delete') {
        tasks.removeAt(index);
      } else if (result is Map<String, dynamic>) {
        tasks[index] = result;
      }
      box.write('tasks', tasks);
    }
  }

  List<Map<String, dynamic>> _getFilteredTasks() {
    if (selectedStatus.value == 'All') {
      return tasks.toList();
    }
    return tasks
        .where((task) => task['status'] == selectedStatus.value)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OnGoing':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statusOptions.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final status = _statusOptions[index];
                        return Obx(() {
                          final isSelected = selectedStatus.value == status;
                          return GestureDetector(
                            onTap: () => selectedStatus.value = status,
                            child: Chip(
                              label: Text(
                                status,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                              backgroundColor:
                                  isSelected
                                      ? status == 'All'
                                          ? Colors.indigo
                                          : _getStatusColor(status)
                                      : Colors.grey.shade200,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final filteredTasks = _getFilteredTasks();
                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedStatus.value == 'All'
                              ? 'No tasks added yet.'
                              : 'No ${selectedStatus.value} tasks found.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (selectedStatus.value != 'All')
                          TextButton.icon(
                            icon: const Icon(Icons.filter_list),
                            label: const Text('Show all tasks'),
                            onPressed: () => selectedStatus.value = 'All',
                          ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final originalIndex = tasks.indexWhere(
                      (t) =>
                          t['title'] == task['title'] &&
                          t['startDate'] == task['startDate'],
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _navigateToTaskDetail(task, originalIndex),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  task['status'],
                                ).withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task['title'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(task['status']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      task['status'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    Colors.green,
                                    'Start:',
                                    _formatDate(task['startDate']),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.flag,
                                    Colors.red,
                                    'Deadline:',
                                    _formatDate(task['deadline']),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.notifications_active,
                                    Colors.orange,
                                    'Next Reminder:',
                                    _formatDateTime(task['nextReminder']),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        backgroundColor: Colors.indigo,
        elevation: 4,
        child: const Icon(Icons.add, size: 40, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildInfoRow(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          '$label ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return _dateFormat.format(date);
  }

  String _formatDateTime(String isoDateTime) {
    final dateTime = DateTime.parse(isoDateTime);
    return _dateTimeFormat.format(dateTime);
  }
}
