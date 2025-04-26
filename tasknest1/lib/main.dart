import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tasknest1/views/task_deatil_screen.dart';
import 'views/splash_screen.dart';
import 'views/home_screen.dart';
import 'views/add_task_screen.dart';
import 'views/calendar_screen.dart';
import 'views/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  //await GetStorage().erase(); // 👈 This clears old data
  runApp(TaskNestApp());
}

class TaskNestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TaskNest',
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
