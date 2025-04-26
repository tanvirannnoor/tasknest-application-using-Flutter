import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Map<String, dynamic> task;
  late int taskIndex;
  late bool isEditing;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _reminderNotesController;
  late TextEditingController _remarksController;

  late DateTime _startDate;
  late DateTime _deadline;
  late DateTime _nextReminder;
  late String _status;

  final List<String> _statusOptions = ['Pending', 'OnGoing', 'Done'];
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy - hh:mm a');

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    task = Map<String, dynamic>.from(args['task']);
    taskIndex = args['index'];
    isEditing = false;

    _titleController = TextEditingController(text: task['title']);
    _descriptionController = TextEditingController(text: task['description']);
    _reminderNotesController = TextEditingController(
      text: task['reminderNotes'] ?? '',
    );
    _remarksController = TextEditingController(text: task['remarks'] ?? '');

    _startDate = DateTime.parse(task['startDate']);
    _deadline = DateTime.parse(task['deadline']);
    _nextReminder = DateTime.parse(task['nextReminder']);
    _status = task['status'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _reminderNotesController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _deadline,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _startDate.hour,
            _startDate.minute,
          );
        } else {
          _deadline = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _deadline.hour,
            _deadline.minute,
          );
        }
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _nextReminder,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_nextReminder),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.indigo,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _nextReminder = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedTask = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'startDate': _startDate.toIso8601String(),
        'deadline': _deadline.toIso8601String(),
        'nextReminder': _nextReminder.toIso8601String(),
        'reminderNotes': _reminderNotesController.text,
        'status': _status,
        'remarks': _remarksController.text,
      };

      Get.back(result: updatedTask);
    }
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.back(result: 'delete');
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
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
        title: const Text('Task Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteTask),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(_status),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(_status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        isEditing
                            ? TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.title,
                                  color: Colors.indigo,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            )
                            : Text(
                              task['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionTitle('Description'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        isEditing
                            ? TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.description,
                                  color: Colors.indigo,
                                ),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            )
                            : Text(task['description']),
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionTitle('Dates & Times'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        isEditing
                            ? _buildEditableDateTile(
                              title: 'Start Date',
                              date: _startDate,
                              icon: Icons.play_circle_outline,
                              iconColor: Colors.green,
                              onTap: () => _selectDate(context, true),
                            )
                            : _buildInfoTile(
                              title: 'Start Date',
                              value: _dateFormat.format(_startDate),
                              icon: Icons.play_circle_outline,
                              iconColor: Colors.green,
                            ),
                        const Divider(height: 1),
                        isEditing
                            ? _buildEditableDateTile(
                              title: 'Deadline',
                              date: _deadline,
                              icon: Icons.flag,
                              iconColor: Colors.red,
                              onTap: () => _selectDate(context, false),
                            )
                            : _buildInfoTile(
                              title: 'Deadline',
                              value: _dateFormat.format(_deadline),
                              icon: Icons.flag,
                              iconColor: Colors.red,
                            ),
                        const Divider(height: 1),
                        isEditing
                            ? ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: const Text('Next Reminder'),
                              subtitle: Text(
                                _dateTimeFormat.format(_nextReminder),
                              ),
                              trailing: const Icon(
                                Icons.edit_calendar,
                                size: 16,
                              ),
                              onTap: () => _selectDateTime(context),
                            )
                            : _buildInfoTile(
                              title: 'Next Reminder',
                              value: _dateTimeFormat.format(_nextReminder),
                              icon: Icons.notifications_active,
                              iconColor: Colors.orange,
                            ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionTitle('Additional Information'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (isEditing) ...[
                          TextFormField(
                            controller: _reminderNotesController,
                            decoration: InputDecoration(
                              labelText: 'Reminder Notes',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.note_alt,
                                color: Colors.orange,
                              ),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.pending_actions,
                                color: Colors.purple,
                              ),
                            ),
                            items:
                                _statusOptions.map((String value) {
                                  Color chipColor = _getStatusColor(value);
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: chipColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(value),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _status = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _remarksController,
                            decoration: InputDecoration(
                              labelText: 'Remarks',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.comment,
                                color: Colors.teal,
                              ),
                            ),
                            maxLines: 2,
                          ),
                        ] else ...[
                          _buildInfoTile(
                            title: 'Reminder Notes',
                            value: task['reminderNotes'] ?? 'No notes',
                            icon: Icons.note_alt,
                            iconColor: Colors.orange,
                          ),
                          const Divider(height: 24),
                          _buildInfoTile(
                            title: 'Remarks',
                            value: task['remarks'] ?? 'No remarks',
                            icon: Icons.comment,
                            iconColor: Colors.teal,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (isEditing) ...[
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _toggleEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          !isEditing
              ? FloatingActionButton(
                onPressed: _toggleEdit,
                backgroundColor: Colors.indigo,
                child: const Icon(Icons.edit, color: Colors.white, size: 30),
              )
              : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildEditableDateTile({
    required String title,
    required DateTime date,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title),
      subtitle: Text(_dateFormat.format(date)),
      trailing: const Icon(Icons.edit_calendar, size: 16),
      onTap: onTap,
    );
  }
}
