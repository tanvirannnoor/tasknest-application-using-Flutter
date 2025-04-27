import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import '../models/task_model.dart';

class NotificationController extends GetxController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _box = GetStorage();

  // Notification settings
  bool get notificationsEnabled => _box.read('notifications') ?? true;
  String get reminderTime => _box.read('reminderTime') ?? '30 minutes before';
  bool get vibrationEnabled => _box.read('vibration') ?? true;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  // Public method to initialize notifications
  Future<void> initializeNotifications() async {
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Request permissions for iOS
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (!GetPlatform.isIOS) return;

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
      // Navigate to specific task using payload
      // Example: Get.to(() => TaskDetailScreen(taskId: payload));
    }
  }

  Duration _getReminderOffset() {
    switch (reminderTime) {
      case '10 minutes before':
        return const Duration(minutes: 10);
      case '30 minutes before':
        return const Duration(minutes: 30);
      case '1 hour before':
        return const Duration(hours: 1);
      case '1 day before':
        return const Duration(days: 1);
      default:
        return const Duration(minutes: 30);
    }
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (!notificationsEnabled || task.deadline == null) return;

    final reminderOffset = _getReminderOffset();
    final scheduledDate = task.deadline!.subtract(reminderOffset);

    // Don't schedule if the time is in the past
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final androidNotificationDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming tasks',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: vibrationEnabled,
    );

    final iOSNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      'Task Reminder: ${task.title}',
      task.description,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: task.id,
    );

    debugPrint(
      'Notification scheduled for task: ${task.title} at $scheduledDate',
    );
  }

  Future<void> cancelTaskNotification(String taskId) async {
    await flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
    debugPrint('Notification canceled for task: $taskId');
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All notifications canceled');
  }

  Future<void> updateAllTaskNotifications(List<Task> tasks) async {
    if (!notificationsEnabled) {
      await cancelAllNotifications();
      return;
    }

    // Cancel all notifications first
    await cancelAllNotifications();

    // Schedule notifications for all tasks with deadlines
    for (final task in tasks) {
      if (task.deadline != null) {
        await scheduleTaskNotification(task);
      }
    }
  }
}
