import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:tasknest1/controllers/task_controller.dart';
import 'package:tasknest1/controllers/theme_controller.dart';
import 'package:tasknest1/controllers/notification_controller.dart';
import 'package:tasknest1/models/task_model.dart';
import 'widgets/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskController taskController = Get.find();
  final ThemeController themeController = Get.find();
  final NotificationController notificationController = Get.find();

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
    if (savedTasks == null) {
      tasks.clear(); // No tasks yet
      return;
    }
    tasks.assignAll(List<Map<String, dynamic>>.from(savedTasks));
    if (notificationController.notificationsEnabled) {
      _scheduleNotificationsForTasks();
    }
  } catch (e) {
    debugPrint('Error loading tasks: $e');
    tasks.clear();
  }
}


  void _scheduleNotificationsForTasks() {
    for (var task in tasks) {
      if (task['nextReminder'] != null &&
          DateTime.parse(task['nextReminder']).isAfter(DateTime.now()) &&
          task['status'] != 'Done') {
        _scheduleTaskNotification(task);
      }
    }
  }

  // This replaces the task creation in HomeScreen's _scheduleTaskNotification method
  void _scheduleTaskNotification(Map<String, dynamic> task) {
    if (!notificationController.notificationsEnabled) return;

    try {
      final taskId = task['id'] ?? task['title'].hashCode.toString();
      final DateTime? reminderDate =
          task['nextReminder'] != null
              ? DateTime.parse(task['nextReminder'])
              : null;
      final DateTime? deadline =
          task['deadline'] != null ? DateTime.parse(task['deadline']) : null;

      // Convert to Task model for the notification controller
      final taskModel = Task(
        id: taskId,
        title: task['title'] ?? 'Task Reminder',
        description: task['description'],
        deadline: deadline,
        status: task['status'] ?? 'Pending',
        nextReminder: reminderDate,
        reminderNotes: task['reminderNotes'],
        remarks: task['remarks'],
        startDate:
            task['startDate'] != null
                ? DateTime.parse(task['startDate'])
                : null,
      );

      notificationController.scheduleTaskNotification(taskModel);
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  void _navigateToAddTask() async {
    final result = await Get.toNamed('/add_task');
    if (result != null && result is Map<String, dynamic>) {
      // Generate unique ID if not present
      if (result['id'] == null) {
        result['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      tasks.add(result);
      box.write('tasks', tasks);

      // Schedule notification for the new task
      if (result['nextReminder'] != null) {
        _scheduleTaskNotification(result);
      }
    }
  }

  void _navigateToTaskDetail(Map<String, dynamic> task, int index) async {
    final result = await Get.toNamed(
      '/task_detail',
      arguments: {'task': task, 'index': index},
    );

    if (result != null) {
      if (result == 'delete') {
        // Cancel notification if task is deleted
        final taskId = task['id'] ?? task['title'].hashCode.toString();
        notificationController.cancelTaskNotification(taskId);
        tasks.removeAt(index);
      } else if (result is Map<String, dynamic>) {
        // Cancel old notification and schedule new one if task is updated
        final taskId = task['id'] ?? task['title'].hashCode.toString();
        notificationController.cancelTaskNotification(taskId);

        tasks[index] = result;

        // Schedule new notification if needed
        if (result['nextReminder'] != null &&
            result['status'] != 'Done' &&
            DateTime.parse(result['nextReminder']).isAfter(DateTime.now())) {
          _scheduleTaskNotification(result);
        }
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
        return Get.theme.colorScheme.primary;
      case 'Pending':
        return Get.theme.colorScheme.secondary;
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
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Get.theme.colorScheme.background,
              Get.theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color:
                        Get.isDarkMode
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.primary,
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
                                          : Get
                                              .theme
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                              backgroundColor:
                                  isSelected
                                      ? status == 'All'
                                          ? Get.theme.colorScheme.primary
                                          : _getStatusColor(status)
                                      : Get.theme.disabledColor.withOpacity(
                                        0.2,
                                      ),
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
                          color: Get.theme.disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedStatus.value == 'All'
                              ? 'No tasks added yet.'
                              : 'No ${selectedStatus.value} tasks found.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Get.theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (selectedStatus.value != 'All')
                          TextButton.icon(
                            icon: Icon(
                              Icons.filter_list,
                              color: Get.theme.colorScheme.primary,
                            ),
                            label: Text(
                              'Show all tasks',
                              style: TextStyle(
                                color: Get.theme.colorScheme.primary,
                              ),
                            ),
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
                                ).withOpacity(Get.isDarkMode ? 0.3 : 0.1),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color:
                                            Get
                                                .theme
                                                .textTheme
                                                .titleMedium
                                                ?.color,
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
                                  if (task['nextReminder'] != null)
                                    _buildInfoRow(
                                      Icons.notifications_active,
                                      Get.theme.colorScheme.secondary,
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
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        backgroundColor: Get.theme.colorScheme.primary,
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
          backgroundColor: color.withOpacity(Get.isDarkMode ? 0.3 : 0.2),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          '$label ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Get.theme.textTheme.bodyMedium?.color),
          ),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return _dateFormat.format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatDateTime(String isoDateTime) {
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return _dateTimeFormat.format(dateTime);
    } catch (e) {
      return 'Invalid date/time';
    }
  }
}
