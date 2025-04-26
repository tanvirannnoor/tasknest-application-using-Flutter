import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed('/home');
    });

    return Scaffold(
      body: Center(
        child: Text('TaskNest', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
