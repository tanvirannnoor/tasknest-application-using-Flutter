import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'widgets/bottom_navbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final box = GetStorage();

  // Settings variables
  final RxBool _darkMode = false.obs;
  final RxBool _notifications = true.obs;
  final RxString _theme = 'Indigo'.obs;
  final RxString _reminderTime = '30 minutes before'.obs;
  final RxBool _vibration = true.obs;
  final RxBool _showCompleted = true.obs;

  final List<String> _themes = ['Indigo', 'Purple', 'Teal', 'Orange', 'Red'];
  final List<String> _reminderTimes = [
    '10 minutes before',
    '30 minutes before',
    '1 hour before',
    '1 day before',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _darkMode.value = box.read('darkMode') ?? false;
    _notifications.value = box.read('notifications') ?? true;
    _theme.value = box.read('theme') ?? 'Indigo';
    _reminderTime.value = box.read('reminderTime') ?? '30 minutes before';
    _vibration.value = box.read('vibration') ?? true;
    _showCompleted.value = box.read('showCompleted') ?? true;
  }

  void _saveSettings() {
    box.write('darkMode', _darkMode.value);
    box.write('notifications', _notifications.value);
    box.write('theme', _theme.value);
    box.write('reminderTime', _reminderTime.value);
    box.write('vibration', _vibration.value);
    box.write('showCompleted', _showCompleted.value);

    Get.snackbar(
      'Settings Saved',
      'Your preferences have been updated',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.indigo.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  Color _getThemeColor(String theme) {
    switch (theme) {
      case 'Purple':
        return Colors.purple;
      case 'Teal':
        return Colors.teal;
      case 'Orange':
        return Colors.orange;
      case 'Red':
        return Colors.red;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingsHeader('Appearance'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Dark Mode',
              'Enable dark theme',
              Icons.dark_mode,
              Colors.indigo,
              _darkMode,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.color_lens, color: Colors.indigo),
                        const SizedBox(width: 12),
                        const Text(
                          'Theme Color',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            _themes.map((theme) {
                              final isSelected = _theme.value == theme;
                              return GestureDetector(
                                onTap: () => _theme.value = theme,
                                child: Container(
                                  width: 70,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? _getThemeColor(
                                              theme,
                                            ).withOpacity(0.2)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _getThemeColor(theme),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: _getThemeColor(theme),
                                          shape: BoxShape.circle,
                                          boxShadow:
                                              isSelected
                                                  ? [
                                                    BoxShadow(
                                                      color: _getThemeColor(
                                                        theme,
                                                      ).withOpacity(0.4),
                                                      blurRadius: 8,
                                                      spreadRadius: 2,
                                                    ),
                                                  ]
                                                  : null,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        theme,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildSettingsHeader('Notifications'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Enable Notifications',
              'Get reminders for your tasks',
              Icons.notifications_active,
              Colors.orange,
              _notifications,
            ),
            const SizedBox(height: 8),
            Obx(
              () =>
                  _notifications.value
                      ? _buildDropdownTile(
                        'Default Reminder Time',
                        'When to be notified before deadlines',
                        Icons.timer,
                        Colors.orange,
                        _reminderTime,
                        _reminderTimes,
                      )
                      : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            Obx(
              () =>
                  _notifications.value
                      ? _buildSwitchTile(
                        'Vibration',
                        'Vibrate when notifications arrive',
                        Icons.vibration,
                        Colors.orange,
                        _vibration,
                      )
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),
            _buildSettingsHeader('Task Display'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Show Completed Tasks',
              'Display completed tasks in calendar',
              Icons.check_circle,
              Colors.green,
              _showCompleted,
            ),

            const SizedBox(height: 32),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.indigo, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'Task Manager v1.0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Made with Flutter',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.indigo.shade200, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    RxBool value,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Obx(
          () => SwitchListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitle),
            secondary: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            value: value.value,
            activeColor: color,
            onChanged: (bool newValue) {
              value.value = newValue;
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    RxString value,
    List<String> options,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value.value,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: color),
                    items:
                        options.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        value.value = newValue;
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
