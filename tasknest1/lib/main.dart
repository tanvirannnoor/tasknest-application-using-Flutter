import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tasknest1/controllers/notification_controller.dart';
import 'package:tasknest1/controllers/task_controller.dart';
import 'package:tasknest1/controllers/theme_controller.dart';
import 'package:tasknest1/themes/app_themes.dart';
import 'package:tasknest1/views/task_deatil_screen.dart';
import 'views/splash_screen.dart';
import 'views/home_screen.dart';
import 'views/add_task_screen.dart';
import 'views/calendar_screen.dart';
import 'views/settings_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await GetStorage.init();
  
  // Initialize theme controller
  Get.put(ThemeController());
  
  // Initialize notification controller
  Get.put(NotificationController());
  
  // Create task controller
  Get.put(TaskController());

  runApp(TaskNestApp());
}

class TaskNestApp extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TaskNest',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/add_task', page: () => AddTaskScreen()),
        GetPage(name: '/task_detail', page: () => TaskDetailScreen()),
        GetPage(name: '/calendar', page: () => CalendarScreen()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
      ],
    );
  }
}