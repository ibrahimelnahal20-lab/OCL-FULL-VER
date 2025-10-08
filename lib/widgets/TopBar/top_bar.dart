// lib/widgets/TopBar/top_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/widgets/Notification/notification_controller.dart';
import 'package:ocl2/Theme/theme_controller.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:ocl2/widgets/Notification/notification_widget.dart';
import 'package:ocl2/widgets/Avatar/user_avatar_widget.dart';

class TopBarWidget extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();
  final TopBarController topBarController = Get.put(TopBarController());
  final NotificationController notificationController = Get.put(
    NotificationController(),
  );

  TopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ThemeMode currentMode = themeController.currentThemeMode.value;

      bool isDark;
      if (currentMode == ThemeMode.system) {
        isDark = Get.isDarkMode;
      } else {
        isDark = (currentMode == ThemeMode.dark);
      }

      final ThemeData currentActiveTheme = themeController.activeThemeData;

      // Enhanced gradient colors for better visual appeal
      final List<Color> darkGradientColors = [
        const Color(0xFF0A0E21),
        const Color(0xFF1A1F35),
        const Color(0xFF2D3748),
      ];

      final List<Color> lightGradientColors = [
        const Color(0xFFFFFFFF),
        const Color(0xFFF8FAFC),
        const Color(0xFFF1F5F9),
      ];

      Color iconBgColor =
          isDark ? Colors.white.withOpacity(0.12) : Colors.grey.shade100;
      Color iconHoverColor =
          isDark ? Colors.white.withOpacity(0.18) : Colors.grey.shade200;
      Color usernameTextColor =
          isDark ? Colors.white.withOpacity(0.95) : Colors.grey.shade800;
      Color iconColor =
          currentActiveTheme.iconTheme.color ??
          (isDark ? Colors.white70 : Colors.grey.shade700);

      return Container(
        height: 75,
        margin: const EdgeInsets.only(top: 12, left: 260, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? darkGradientColors : lightGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.8),
              blurRadius: 1,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Enhanced greeting section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [Colors.blue.shade600, Colors.purple.shade600]
                              : [Colors.blue.shade400, Colors.purple.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.blue : Colors.blue.shade400)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Text(
                        "Hi, ${topBarController.loggedInUsername.value}",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: usernameTextColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Text(
                      "Welcome back!",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.6)
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Enhanced action buttons
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.notifications_outlined,
                  isDark: isDark,
                  iconColor: iconColor,
                  bgColor: iconBgColor,
                  hoverColor: iconHoverColor,
                  child: NotificationWidget(),
                  tooltip: "Notifications",
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon:
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                  isDark: isDark,
                  iconColor: iconColor,
                  bgColor: iconBgColor,
                  hoverColor: iconHoverColor,
                  onTap: themeController.toggleTheme,
                  tooltip:
                      isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
                ),
                const SizedBox(width: 20),
                // Enhanced avatar with border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: UserAvatarWidget(size: 48),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isDark,
    required Color iconColor,
    required Color bgColor,
    required Color hoverColor,
    Widget? child,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          hoverColor: hoverColor,
          splashColor: (isDark ? Colors.white : Colors.blue).withOpacity(0.1),
          child: Tooltip(
            message: tooltip ?? "",
            child: Center(
              child: child ?? Icon(icon, color: iconColor, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
