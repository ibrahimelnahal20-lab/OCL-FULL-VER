// lib/Team/team_page.dart
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ocl2/Team/team_controller.dart.dart';
import 'package:ocl2/Theme/theme_controller.dart';
import 'package:ocl2/widgets/TopBar/top_bar.dart';
import 'package:ocl2/widgets/SideBar/sidebar.dart';
import 'package:ocl2/widgets/team_card_widget.dart';

class TeamPage extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();
  final TeamController teamController = Get.put(TeamController());

  TeamPage({super.key});

  // Enhanced color scheme for better visual appeal
  static const List<Color> dmGradientColors = [
    Color(0xFF0A0E21),
    Color(0xFF1A1F35),
    Color(0xFF2D3748),
    Color(0xFF4A5568),
  ];

  static const Color dmCardColor = Color(0xFF1A1F35);
  static const Color dmSurfaceColor = Color(0xFF2D3748);
  static const Color dmBorderColor = Color(0xFF4A5568);
  static const Color dmTextColorPrimary = Colors.white;
  static const Color dmTextColorSecondary = Colors.white70;
  static const Color dmIconColor = Colors.white70;
  static Color dmFocusColor = Colors.blue.shade400;

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 650) {
      return 1;
    } else if (screenWidth < 1000) {
      return 2;
    } else if (screenWidth < 1350) {
      return 3;
    } else {
      return 4;
    }
  }

  double _getChildAspectRatio(int crossAxisCount) {
    if (crossAxisCount == 1) {
      return 1.1;
    } else if (crossAxisCount == 2) {
      return 1.05;
    } else if (crossAxisCount == 3) {
      return 1.0;
    }
    return 0.95;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ThemeMode currentMode = themeController.currentThemeMode.value;

      bool isCurrentlyDark;
      if (currentMode == ThemeMode.system) {
        isCurrentlyDark = Get.isDarkMode;
      } else {
        isCurrentlyDark = (currentMode == ThemeMode.dark);
      }

      // Enhanced color definitions
      final Color headerColor =
          isCurrentlyDark ? dmTextColorPrimary : Colors.grey.shade800;
      final Color defaultTextColor =
          isCurrentlyDark ? dmTextColorSecondary : Colors.grey.shade600;
      final Color circularProgressColor =
          isCurrentlyDark ? dmFocusColor : Colors.blue.shade500;

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  isCurrentlyDark
                      ? dmGradientColors
                      : [
                        Colors.white,
                        Colors.grey.shade50,
                        Colors.blue.shade50,
                      ],
              stops:
                  isCurrentlyDark
                      ? const [0.0, 0.3, 0.7, 1.0]
                      : const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Sidebar(isDarkMode: isCurrentlyDark),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 95,
                          left: 32,
                          right: 32,
                          bottom: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Enhanced header section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors:
                                          isCurrentlyDark
                                              ? [
                                                Colors.teal.shade600,
                                                Colors.blue.shade600,
                                              ]
                                              : [
                                                Colors.teal.shade500,
                                                Colors.blue.shade500,
                                              ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isCurrentlyDark
                                                ? Colors.teal
                                                : Colors.teal.shade400)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.people_alt,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Team & Managers",
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: headerColor,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        "Manage and collaborate with your team members",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: defaultTextColor,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Enhanced team statistics
                            _buildTeamStatistics(
                              teamController,
                              isCurrentlyDark,
                              defaultTextColor,
                            ),

                            const SizedBox(height: 32),

                            // Enhanced team members section
                            Expanded(
                              child: Obx(() {
                                if (teamController.isLoading.value) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color:
                                                isCurrentlyDark
                                                    ? Colors.grey.shade800
                                                    : Colors.grey.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  circularProgressColor,
                                                ),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Loading your team...",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: defaultTextColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (teamController.teamMembers.isEmpty) {
                                  return _buildEmptyState(
                                    isCurrentlyDark,
                                    defaultTextColor,
                                  );
                                }

                                final crossAxisCount = _getCrossAxisCount(
                                  context,
                                );
                                final childAspectRatio = _getChildAspectRatio(
                                  crossAxisCount,
                                );

                                return Container(
                                  decoration: BoxDecoration(
                                    color:
                                        isCurrentlyDark
                                            ? dmSurfaceColor.withOpacity(0.3)
                                            : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          isCurrentlyDark
                                              ? dmBorderColor.withOpacity(0.3)
                                              : Colors.grey.shade200,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            isCurrentlyDark
                                                ? Colors.black.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: GridView.builder(
                                      padding: const EdgeInsets.all(20),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20,
                                            childAspectRatio: childAspectRatio,
                                          ),
                                      itemCount:
                                          teamController.teamMembers.length,
                                      itemBuilder: (context, index) {
                                        final member =
                                            teamController.teamMembers[index];
                                        return TeamCardWidget(
                                          name: member["username"] ?? "N/A",
                                          jobTitle: member["jobTitle"] ?? "N/A",
                                          description:
                                              member["description"] ?? "",
                                          imageUrl:
                                              "http://ahmedlogicpro-001-site5.qtempurl.com${member["imageUrl"]}",
                                          userType:
                                              member["userType"] ?? "Member",
                                          isPinned: index == 0,
                                          allTasks:
                                              member["allTasks"] as int? ?? 0,
                                          completedTasks:
                                              member["completedTasks"]
                                                  as int? ??
                                              0,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                TopBarWidget(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTeamStatistics(
    TeamController controller,
    bool isDark,
    Color defaultTextColor,
  ) {
    int totalMembers = controller.teamMembers.length;
    int totalTasks = controller.teamMembers.fold(
      0,
      (sum, member) => sum + (member["allTasks"] as int? ?? 0),
    );
    int completedTasks = controller.teamMembers.fold(
      0,
      (sum, member) => sum + (member["completedTasks"] as int? ?? 0),
    );
    double completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [dmSurfaceColor, dmCardColor]
                  : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? dmBorderColor.withOpacity(0.3) : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatCard(
            "Team Members",
            totalMembers,
            Icons.people,
            isDark ? Colors.teal.shade400 : Colors.teal.shade500,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            "Total Tasks",
            totalTasks,
            Icons.task_alt,
            isDark ? Colors.blue.shade400 : Colors.blue.shade500,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            "Completed",
            completedTasks,
            Icons.check_circle,
            isDark ? Colors.green.shade400 : Colors.green.shade500,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            "Completion Rate",
            completionRate.toInt(),
            Icons.trending_up,
            isDark ? Colors.orange.shade400 : Colors.orange.shade500,
            isDark,
            isPercentage: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    int count,
    IconData icon,
    Color color,
    bool isDark, {
    bool isPercentage = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPercentage ? "$count%" : count.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color defaultTextColor) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color:
              isDark
                  ? dmSurfaceColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isDark ? dmBorderColor.withOpacity(0.3) : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No team members found",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add new members to see them here",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: defaultTextColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.teal : Colors.teal.shade500)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isDark ? Colors.teal : Colors.teal.shade500)
                      .withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                "Team members will appear here once added",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
