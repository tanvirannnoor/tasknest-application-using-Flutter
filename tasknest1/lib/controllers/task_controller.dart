import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../models/task_model.dart';
import 'notification_controller.dart';

class TaskController extends GetxController {
  final _box = GetStorage();
  final _key = 'tasks';
  final RxList<Task> tasks = <Task>[].obs;
  final NotificationController notificationController = Get.find();

  @override
  void onInit() {
    super.onInit();
    _loadTasks();
  }

  void _loadTasks() {
  try {
    final tasksData = _box.read(_key);

    if (tasksData == null) {
      tasks.value = []; // No data yet — safe empty list
      return;
    }

    if (tasksData is String) {
      final List<dynamic> decodedTasks = json.decode(tasksData);
      tasks.value = decodedTasks.map((task) => Task.fromJson(task)).toList();
    } else if (tasksData is List) {
      tasks.value = List<Task>.from(
        tasksData.map((item) => Task.fromJson(Map<String, dynamic>.from(item))),
      );
    } else {
      tasks.value = []; // Unknown data — fallback
    }
  } catch (e) {
    debugPrint('Error loading tasks: $e');
    tasks.value = [];
  }
}


  Future<void> _saveTasks() async {
    await _box.write(_key, tasks.map((task) => task.toJson()).toList());
    // Schedule notifications for all tasks
    await notificationController.updateAllTaskNotifications(tasks);
  }

  void addTask(Task task) {
    tasks.add(task);
    _saveTasks();
  }

  void updateTask(Task updatedTask) {
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      _saveTasks();
    }
  }

  void deleteTask(String taskId) {
    tasks.removeWhere((task) => task.id == taskId);
    _saveTasks();
    notificationController.cancelTaskNotification(taskId);
  }

  void toggleTaskCompletion(String taskId) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      _saveTasks();
      if (tasks[index].isCompleted) {
        notificationController.cancelTaskNotification(taskId);
      } else if (tasks[index].deadline != null) {
        notificationController.scheduleTaskNotification(tasks[index]);
      }
    }
  }

  List<Task> getUpcomingTasks() {
    final now = DateTime.now();
    return tasks
        .where(
          (task) =>
              !task.isCompleted &&
              task.deadline != null &&
              task.deadline!.isAfter(now),
        )
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
  }
}
