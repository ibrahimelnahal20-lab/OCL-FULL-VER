import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final GetStorage _box = GetStorage();
  final String _themePersistenceKey =
      'appCurrentThemeModeV2'; // Using a versioned key

  final Rx<ThemeMode> currentThemeMode = ThemeMode.system.obs;

  // This getter will reflect the effective dark mode state managed by GetX
  bool get isDarkMode => Get.isDarkMode;

  @override
  void onInit() {
    super.onInit();
    _loadThemeModeFromPrefs();
  }

  void _loadThemeModeFromPrefs() {
    final int? themeIndex = _box.read(_themePersistenceKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < ThemeMode.values.length) {
      final persistedMode = ThemeMode.values[themeIndex];
      // Call setThemeMode to also update GetX's internal theme state
      setThemeMode(persistedMode, saveToPrefs: false);
    } else {
      // If nothing is saved, default to system.
      // This will also call Get.changeThemeMode(ThemeMode.system)
      setThemeMode(ThemeMode.system, saveToPrefs: false);
    }
  }

  void setThemeMode(ThemeMode mode, {bool saveToPrefs = true}) {
    currentThemeMode.value = mode;
    Get.changeThemeMode(
      mode,
    ); // This is crucial for GetX and updates Get.isDarkMode

    if (saveToPrefs) {
      _box.write(_themePersistenceKey, mode.index);
    }
  }

  void toggleTheme() {
    // Get.isDarkMode (our getter) will reflect the current effective state
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(newMode);
  }

  // --- Custom Light Theme ---
  ThemeData get lightTheme => ThemeData.light().copyWith(
    primaryColor: const Color(0xFF5577FF),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: const Color(0xFF5577FF),
      secondary: const Color(0xFF03DAC6),
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    cardColor: Colors.white,
    textTheme: ThemeData.light().textTheme
        .copyWith(
          bodyLarge: const TextStyle(color: Colors.black87),
          titleLarge: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        )
        .apply(fontFamily: 'Poppins'),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5577FF),
        foregroundColor: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5577FF),
      foregroundColor: Colors.white,
      elevation: 0.5,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5577FF), width: 2),
      ),
    ),
  );

  // --- Custom Dark Theme ---
  ThemeData get darkTheme => ThemeData.dark().copyWith(
    primaryColor: const Color(0xFF6A88FF),
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ThemeData.dark().colorScheme.copyWith(
      primary: const Color(0xFF6A88FF),
      secondary: const Color(0xFF03DAC6),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white70,
    ),
    cardColor: const Color(0xFF1E1E1E),
    textTheme: ThemeData.dark().textTheme
        .copyWith(
          bodyLarge: const TextStyle(color: Colors.white70),
          titleLarge: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
        .apply(fontFamily: 'Poppins'),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A88FF),
        foregroundColor: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white70,
      elevation: 0.5,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      hintStyle: TextStyle(color: Colors.grey[500]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6A88FF), width: 2),
      ),
    ),
  );

  // Getter for the currently active theme data
  ThemeData get activeThemeData {
    // When Get.changeThemeMode is called with ThemeMode.system,
    // GetX handles listening to platform brightness and applies the correct theme.
    // Get.isDarkMode will reflect this.
    return isDarkMode ? darkTheme : lightTheme;
  }
}
