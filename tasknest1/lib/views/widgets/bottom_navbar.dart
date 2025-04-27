import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  BottomNavBar({this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0 && currentIndex != 0) {
          Get.offAllNamed('/home');
        } else if (index == 1 && currentIndex != 1) {
          Get.offAllNamed('/calendar');
        } else if (index == 2 && currentIndex != 2) {
          Get.offAllNamed('/settings');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}