import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> task = Get.arguments ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Task Details'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['title'] ?? 'No Title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              task['description'] ?? 'No Description',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Start Date: ${_formatDate(task['startDate'])}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              'Deadline: ${_formatDate(task['deadline'])}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              'Status: ${task['status'] ?? 'Pending'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
