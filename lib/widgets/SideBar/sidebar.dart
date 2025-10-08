// lib/widgets/SideBar/sidebar.dart

// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/routes/routes.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:ocl2/Login%20-%20Singup/login_controller.dart';

import '../../Theme/theme_controller.dart' show ThemeController;

// ignore: must_be_immutable
class Sidebar extends StatelessWidget {
  final bool isDarkMode;

  const Sidebar({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final TopBarController topBarController = Get.find<TopBarController>();

    // Enhanced gradient colors for better visual appeal
    final List<Color> darkGradientColors = [
      const Color(0xFF0A0E21),
      const Color(0xFF1A1F35),
      const Color(0xFF2D3748),
      const Color(0xFF4A5568),
    ];

    final List<Color> lightGradientColors = [
      const Color(0xFFFFFFFF),
      const Color(0xFFF8FAFC),
      const Color(0xFFF1F5F9),
      const Color(0xFFE2E8F0),
    ];

    final Color activeItemColor =
        isDarkMode
            ? Colors.blue.shade600.withOpacity(0.2)
            : Colors.blue.shade100;
    final Color activeItemTextColor =
        isDarkMode ? Colors.white : Colors.blue.shade700;
    final Color inactiveItemTextColor =
        isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final Color inactiveItemIconColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color logoutBtnColor = Colors.red.shade400;

    return Container(
      width: 240,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode ? darkGradientColors : lightGradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        border: Border(
          right: BorderSide(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Enhanced logo section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDarkMode
                              ? [Colors.blue.shade600, Colors.purple.shade600]
                              : [Colors.blue.shade500, Colors.purple.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isDarkMode ? Colors.blue : Colors.blue.shade400)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "OCL",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Dashboard",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey.shade800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Navigation items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Obx(() {
                final bool isGuest = topBarController.userType.value == 'guest';
                return Column(
                  children: [
                    _buildMenuItem(
                      "assets/icons/dashboard.svg",
                      "Overview",
                      isActive: Get.currentRoute == AppRoutes.home,
                      isDarkMode: isDarkMode,
                      inactiveColor: inactiveItemTextColor,
                      inactiveIconColor: inactiveItemIconColor,
                      activeColor: activeItemColor,
                      activeTextColor: activeItemTextColor,
                      logoutColor: logoutBtnColor,
                      onTap: () {
                        if (Get.currentRoute != AppRoutes.home) {
                          Get.toNamed(AppRoutes.home);
                        }
                      },
                    ),
                    if (!isGuest) ...[
                      _buildMenuItem(
                        "assets/icons/task.svg",
                        "Task",
                        isActive:
                            Get.currentRoute == AppRoutes.userTask ||
                            Get.currentRoute == AppRoutes.task,
                        isDarkMode: isDarkMode,
                        inactiveColor: inactiveItemTextColor,
                        inactiveIconColor: inactiveItemIconColor,
                        activeColor: activeItemColor,
                        activeTextColor: activeItemTextColor,
                        logoutColor: logoutBtnColor,
                        onTap: () {
                          if (topBarController.userType.value == 'user') {
                            if (Get.currentRoute != AppRoutes.userTask) {
                              Get.toNamed(AppRoutes.userTask);
                            }
                          } else {
                            if (Get.currentRoute != AppRoutes.task) {
                              Get.toNamed(AppRoutes.task);
                            }
                          }
                        },
                      ),
                      _buildMenuItem(
                        "assets/icons/sub.svg",
                        "SubTask",
                        isActive:
                            Get.currentRoute == AppRoutes.userSubTask ||
                            Get.currentRoute == AppRoutes.subTask,
                        isDarkMode: isDarkMode,
                        inactiveColor: inactiveItemTextColor,
                        inactiveIconColor: inactiveItemIconColor,
                        activeColor: activeItemColor,
                        activeTextColor: activeItemTextColor,
                        logoutColor: logoutBtnColor,
                        onTap: () {
                          if (topBarController.userType.value == 'user') {
                            if (Get.currentRoute != AppRoutes.userSubTask) {
                              Get.toNamed(AppRoutes.userSubTask);
                            }
                          } else {
                            if (Get.currentRoute != AppRoutes.subTask) {
                              Get.toNamed(AppRoutes.subTask);
                            }
                          }
                        },
                      ),
                      _buildMenuItem(
                        "assets/icons/Team.svg",
                        "Your Team",
                        isActive: Get.currentRoute == AppRoutes.team,
                        isDarkMode: isDarkMode,
                        inactiveColor: inactiveItemTextColor,
                        inactiveIconColor: inactiveItemIconColor,
                        activeColor: activeItemColor,
                        activeTextColor: activeItemTextColor,
                        logoutColor: logoutBtnColor,
                        onTap: () {
                          if (Get.currentRoute != AppRoutes.team) {
                            Get.toNamed(AppRoutes.team);
                          }
                        },
                      ),
                      _buildMenuItem(
                        "assets/icons/attendance.svg",
                        "Attendance",
                        isActive:
                            Get.currentRoute == AppRoutes.attendanceOverview,
                        isDarkMode: isDarkMode,
                        inactiveColor: inactiveItemTextColor,
                        inactiveIconColor: inactiveItemIconColor,
                        activeColor: activeItemColor,
                        activeTextColor: activeItemTextColor,
                        logoutColor: logoutBtnColor,
                        onTap: () {
                          if (Get.currentRoute !=
                              AppRoutes.attendanceOverview) {
                            Get.toNamed(AppRoutes.attendanceOverview);
                          }
                        },
                      ),
                      _buildMenuItem(
                        "assets/icons/chat.svg",
                        "Chats",
                        isActive: Get.currentRoute == AppRoutes.chat,
                        isDarkMode: isDarkMode,
                        inactiveColor: inactiveItemTextColor,
                        inactiveIconColor: inactiveItemIconColor,
                        activeColor: activeItemColor,
                        activeTextColor: activeItemTextColor,
                        logoutColor: logoutBtnColor,
                        onTap: () {
                          if (Get.currentRoute != AppRoutes.chat) {
                            Get.toNamed(AppRoutes.chat);
                          }
                        },
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),

          // Logout button
          Obx(() {
            final bool isGuest = topBarController.userType.value == 'guest';
            if (!isGuest) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: _buildMenuItem(
                  "assets/icons/logout.svg",
                  "Logout",
                  isDarkMode: isDarkMode,
                  isLogout: true,
                  inactiveColor: logoutBtnColor,
                  inactiveIconColor: logoutBtnColor,
                  activeColor: Colors.transparent,
                  activeTextColor: logoutBtnColor,
                  logoutColor: logoutBtnColor,
                  onTap: () => _showLogoutConfirmation(context, isDarkMode),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String iconPath,
    String title, {
    bool isActive = false,
    required bool isDarkMode,
    bool isLogout = false,
    required Color inactiveColor,
    required Color inactiveIconColor,
    required Color activeColor,
    required Color activeTextColor,
    required Color logoutColor,
    VoidCallback? onTap,
  }) {
    final Color textColor =
        isLogout ? logoutColor : (isActive ? activeTextColor : inactiveColor);
    final Color iconColor =
        isLogout
            ? logoutColor
            : (isActive ? activeTextColor : inactiveIconColor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive && !isLogout ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border:
            isActive && !isLogout
                ? Border.all(
                  color:
                      isDarkMode
                          ? Colors.blue.shade400.withOpacity(0.3)
                          : Colors.blue.shade300.withOpacity(0.5),
                  width: 1,
                )
                : null,
        boxShadow:
            isActive && !isLogout
                ? [
                  BoxShadow(
                    color: activeColor.withOpacity(isDarkMode ? 0.2 : 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          hoverColor:
              isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
          splashColor: (isDarkMode
                  ? Colors.white
                  : Theme.of(Get.context!).primaryColor)
              .withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                // Enhanced icon container
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isActive && !isLogout
                            ? (isDarkMode
                                ? Colors.blue.shade600.withOpacity(0.2)
                                : Colors.blue.shade100)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    iconPath,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Active indicator
                if (isActive && !isLogout)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.blue.shade400
                              : Colors.blue.shade500,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, bool isCurrentlyDark) {
    final ThemeController themeController = Get.find<ThemeController>();
    final ThemeData dialogTheme = themeController.activeThemeData;

    Get.defaultDialog(
      title: "Logout Confirmation",
      titleStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: dialogTheme.textTheme.titleLarge?.color,
      ),
      backgroundColor: dialogTheme.cardColor,
      barrierDismissible: false,
      radius: 16,
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              color: Colors.red.shade600,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Are you sure you want to log out?",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: dialogTheme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You'll need to sign in again to access your account.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: dialogTheme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color:
                          dialogTheme.textTheme.bodyMedium?.color?.withOpacity(
                            0.3,
                          ) ??
                          Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: dialogTheme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.find<LoginController>().signOutAndCheckOut();
                  },
                  child: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
