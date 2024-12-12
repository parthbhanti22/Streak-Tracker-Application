import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'streak_tracker_app.dart';

void main() async {
  // Ensures Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open a box for local storage.
  await Hive.initFlutter();
  await Hive.openBox('streakBox');

  // Run the app.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define light and dark themes for the app.
    ThemeData lightTheme = ThemeData(
      primarySwatch: Colors.teal,
      brightness: Brightness.light,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16), // Updated from bodyText2 to bodyMedium
      ),
    );

    ThemeData darkTheme = ThemeData(
      primarySwatch: Colors.teal,
      brightness: Brightness.dark,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16, color: Colors.white), // Updated
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner.
      theme: lightTheme,                // Apply light theme.
      darkTheme: darkTheme,             // Apply dark theme.
      themeMode: ThemeMode.system,      // Automatically switch based on system settings.
      home: StreakTrackerApp(),         // Set the home screen of the app.
    );
  }
}
