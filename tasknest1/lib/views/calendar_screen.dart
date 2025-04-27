import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'widgets/bottom_navbar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final box = GetStorage();
  final tasks = <Map<String, dynamic>>[].obs;
  final selectedEvents = <Map<String, dynamic>>[].obs;
  final displayedEvents = <Map<String, dynamic>>[].obs;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy - hh:mm a');

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  // Filter option
  String _filterOption = 'All';

  @override
  void initState() {
    super.initState();
    _loadTasks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedEvents();
    });
  }

  void _loadTasks() {
    try {
      List<dynamic>? savedTasks = box.read('tasks');
      if (savedTasks == null) {
        tasks.clear();
        return;
      }
      tasks.assignAll(List<Map<String, dynamic>>.from(savedTasks));
      _generateEventMap();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      tasks.clear();
      box.write('tasks', []);
    }
  }

  void _generateEventMap() {
    _events.clear();

    for (var task in tasks) {
      // Add deadline events
      final deadline = DateTime.parse(task['deadline']);
      final deadlineDate = DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
      );

      if (_events[deadlineDate] == null) {
        _events[deadlineDate] = [];
      }
      _events[deadlineDate]!.add({...task, 'eventType': 'deadline'});

      // Add reminder events
      final reminder = DateTime.parse(task['nextReminder']);
      final reminderDate = DateTime(
        reminder.year,
        reminder.month,
        reminder.day,
      );

      if (_events[reminderDate] == null) {
        _events[reminderDate] = [];
      }

      // Only add if there are reminder notes
      if (task['reminderNotes'] != null &&
          task['reminderNotes'].toString().isNotEmpty) {
        _events[reminderDate]!.add({...task, 'eventType': 'reminder'});
      }
    }
  }

  void _updateSelectedEvents() {
    final selectedDate = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    selectedEvents.clear();

    if (_events[selectedDate] != null) {
      selectedEvents.assignAll(_events[selectedDate]!);
    }

    _applyFilter();
  }

  void _applyFilter() {
    displayedEvents.clear();

    switch (_filterOption) {
      case 'All':
        displayedEvents.assignAll(selectedEvents);
        break;
      case 'Reminder':
        displayedEvents.assignAll(
          selectedEvents
              .where((event) => event['eventType'] == 'reminder')
              .toList(),
        );
        break;
      case 'Deadline':
        displayedEvents.assignAll(
          selectedEvents
              .where((event) => event['eventType'] == 'deadline')
              .toList(),
        );
        break;
    }
  }

  void _navigateToTaskDetail(Map<String, dynamic> task) async {
    // Find the original index in the tasks list
    final index = tasks.indexWhere(
      (t) => t['title'] == task['title'] && t['startDate'] == task['startDate'],
    );

    if (index != -1) {
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

        // Refresh events after task update/delete
        _generateEventMap();
        _updateSelectedEvents();
      }
    }
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

  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'deadline':
        return Colors.red;
      case 'reminder':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  Color _getFilterColor(String filterType) {
    switch (filterType) {
      case 'All':
        return Colors.indigo;
      case 'Reminder':
        return Colors.orange;
      case 'Deadline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
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
            Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) {
                    final date = DateTime(day.year, day.month, day.day);
                    return _events[date] ?? [];
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _updateSelectedEvents();
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    // Today decoration
                    todayDecoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    // Selected day decoration
                    selectedDecoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    // Marker decoration
                    markerDecoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    // Weekend text style
                    weekendTextStyle: const TextStyle(color: Colors.red),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    titleCentered: true,
                    formatButtonShowsNext: false,
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox();

                      return Positioned(
                        bottom: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            events.length > 3 ? 3 : events.length,
                            (index) {
                              final event =
                                  events[index] as Map<String, dynamic>;
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.0,
                                ),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getEventTypeColor(event['eventType']),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const _LegendItem(color: Colors.red, label: 'Deadline'),
                      const SizedBox(width: 16),
                      const _LegendItem(
                        color: Colors.orange,
                        label: 'Reminder',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Filter options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFilterOption('All'),
                      const SizedBox(width: 16),
                      _buildFilterOption('Reminder'),
                      const SizedBox(width: 16),
                      _buildFilterOption('Deadline'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (displayedEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filterOption == 'All'
                              ? 'No events for ${_dateFormat.format(_selectedDay)}'
                              : 'No $_filterOption events for ${_dateFormat.format(_selectedDay)}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: displayedEvents.length,
                  itemBuilder: (context, index) {
                    final event = displayedEvents[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _navigateToTaskDetail(event),
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
                                  event['status'],
                                ).withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getEventTypeColor(
                                        event['eventType'],
                                      ).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      event['eventType'] == 'deadline'
                                          ? Icons.flag
                                          : Icons.notifications_active,
                                      color: _getEventTypeColor(
                                        event['eventType'],
                                      ),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['title'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          event['eventType'] == 'deadline'
                                              ? 'Deadline'
                                              : 'Reminder',
                                          style: TextStyle(
                                            color: _getEventTypeColor(
                                              event['eventType'],
                                            ),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(event['status']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      event['status'] ?? '',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (event['eventType'] == 'deadline')
                                    _buildInfoRow(
                                      Icons.calendar_today,
                                      Colors.red,
                                      'Deadline:',
                                      _formatDate(event['deadline']),
                                    ),
                                  if (event['eventType'] == 'reminder')
                                    _buildInfoRow(
                                      Icons.notifications_active,
                                      Colors.orange,
                                      'Reminder:',
                                      _formatDateTime(event['nextReminder']),
                                    ),
                                  const SizedBox(height: 8),
                                  // Only show reminder notes for reminder events
                                  if (event['eventType'] == 'reminder' &&
                                      event['reminderNotes'] != null &&
                                      event['reminderNotes']
                                          .toString()
                                          .isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Notes:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            event['reminderNotes'],
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
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
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildFilterOption(String filterType) {
    final isSelected = _filterOption == filterType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterOption = filterType;
        });
        _applyFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? _getFilterColor(filterType) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? _getFilterColor(filterType) : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Text(
          filterType,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
