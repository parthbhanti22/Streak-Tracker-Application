import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class StreakTrackerApp extends StatefulWidget {
  @override
  _StreakTrackerAppState createState() => _StreakTrackerAppState();
}

class _StreakTrackerAppState extends State<StreakTrackerApp> {
  final _streakBox = Hive.box('streakBox');
  final FlutterLocalNotificationsPlugin _notificationPlugin =
  FlutterLocalNotificationsPlugin();

  TextEditingController _habitController = TextEditingController();
  DateTime _lastCompleted = DateTime.now();
  int _streakCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadStreakData();
  }

  // Initialize notifications
  void _initializeNotifications() async {
    // Timezone initialization
    tz.initializeTimeZones();

    // Android-specific initialization
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: android);
    await _notificationPlugin.initialize(initializationSettings);

    // Schedule notifications
    _scheduleDailyNotifications();
  }

  // Schedule daily notifications
  void _scheduleDailyNotifications() {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    _notificationPlugin.zonedSchedule(
      0,
      'Keep Your Streak!',
      'Don’t forget to work on your habit today!',
      _nextInstanceOfTime(9), // Schedule for 9:00 AM
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Calculate the next instance of the specified time
  tz.TZDateTime _nextInstanceOfTime(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  // Load streak data from Hive
  void _loadStreakData() {
    setState(() {
      _habitController.text = _streakBox.get('habit', defaultValue: '');
      _streakCount = _streakBox.get('streak', defaultValue: 0);
      _lastCompleted = DateTime.tryParse(
          _streakBox.get('lastCompleted', defaultValue: '')) ??
          DateTime.now();
    });
  }

  // Save streak data to Hive
  void _saveStreakData() {
    _streakBox.put('habit', _habitController.text);
    _streakBox.put('streak', _streakCount);
    _streakBox.put('lastCompleted', _lastCompleted.toIso8601String());
  }

  // Increment streak count when habit is completed
  void _incrementStreak() {
    setState(() {
      if (_lastCompleted.day != DateTime.now().day) {
        _lastCompleted = DateTime.now();
        _streakCount++;
        _saveStreakData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Streak Tracker'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _habitController,
              decoration: InputDecoration(
                labelText: 'Your Habit',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveStreakData(),
            ),
            SizedBox(height: 20),
            Text(
              'Current Streak: $_streakCount days',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementStreak,
              child: Text('Mark as Done Today'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
