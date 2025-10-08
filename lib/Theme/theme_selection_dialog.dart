// lib/widgets/theme_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ocl2/Theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences key
const String prefsKeyInitialDialogShown = 'initialThemeDialogShownV2';

class ThemeSelectionDialog extends StatefulWidget {
  final VoidCallback? onDialogDismissed;

  const ThemeSelectionDialog({super.key, this.onDialogDismissed});

  @override
  State<ThemeSelectionDialog> createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  final ThemeController _themeController = Get.find<ThemeController>();
  late ThemeMode _selectedThemeMode;

  @override
  void initState() {
    super.initState();
    _selectedThemeMode = _themeController.currentThemeMode.value;
  }

  Future<void> _applyAndDismiss() async {
    _themeController.setThemeMode(_selectedThemeMode);

    // Always set the flag to true, so the dialog doesn't show again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKeyInitialDialogShown, true);

    widget.onDialogDismissed?.call();
    if (Get.isDialogOpen ?? false) {
      Get.back(); // Dismiss the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    final bool isDark = currentTheme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.palette_rounded,
                color: const Color(0xFF4F46E5),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Choose Your Theme',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              'Select your preferred appearance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Theme Options
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildThemeOption(
                  title: 'Light',
                  icon: Icons.light_mode_outlined,
                  value: ThemeMode.light,
                  isDark: isDark,
                ),
                _buildThemeOption(
                  title: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  value: ThemeMode.dark,
                  isDark: isDark,
                ),
                _buildThemeOption(
                  title: 'System Default',
                  icon: Icons.brightness_auto_outlined,
                  value: ThemeMode.system,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _applyAndDismiss,
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required ThemeMode value,
    required bool isDark,
  }) {
    final bool isSelected = _selectedThemeMode == value;
    final Color primaryColor = const Color(0xFF4F46E5);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected ? primaryColor.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: RadioListTile<ThemeMode>(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? primaryColor.withOpacity(0.2)
                    : (isDark ? Colors.grey[700] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color:
                isSelected
                    ? primaryColor
                    : (isDark ? Colors.white70 : Colors.grey[600]),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color:
                isSelected
                    ? primaryColor
                    : (isDark ? Colors.white : Colors.grey[800]),
          ),
        ),
        value: value,
        groupValue: _selectedThemeMode,
        onChanged: (ThemeMode? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedThemeMode = newValue;
            });
          }
        },
        activeColor: primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        controlAffinity: ListTileControlAffinity.trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
      ),
    );
  }
}
