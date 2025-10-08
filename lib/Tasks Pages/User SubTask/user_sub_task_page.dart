// File: lib/screens/user_sub_task_page.dart

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'user_sub_task_controller.dart';
import 'package:ocl2/widgets/TopBar/top_bar.dart';
import 'package:ocl2/widgets/SideBar/sidebar.dart';

class UserSubTaskPage extends StatelessWidget {
  const UserSubTaskPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    final controller = Get.put(UserSubTaskController());
    final isDark = Get.isDarkMode;

    // Enhanced color definitions
    final Color headerColor =
        isDark ? dmTextColorPrimary : Colors.grey.shade800;
    final Color defaultTextColor =
        isDark ? dmTextColorSecondary : Colors.grey.shade600;

    // Enhanced column colors
    final Color columnCardBgColor =
        isDark ? dmSurfaceColor : Colors.grey.shade50;
    final Color columnBorderColor =
        isDark ? dmBorderColor : Colors.grey.shade200;

    // Enhanced status-specific colors
    final Color notStartedBg =
        isDark ? const Color(0xFF3F51B5) : Colors.indigo.shade50;
    final Color notStartedTxt =
        isDark ? Colors.indigo.shade100 : Colors.indigo.shade900;

    final Color inProgressBg =
        isDark ? const Color(0xFFF57C00) : Colors.orange.shade50;
    final Color inProgressTxt =
        isDark ? Colors.orange.shade100 : Colors.orange.shade900;

    final Color completeBg =
        isDark ? const Color(0xFF388E3C) : Colors.green.shade50;
    final Color completeTxt =
        isDark ? Colors.green.shade100 : Colors.green.shade900;

    final Color circularProgressColor =
        isDark ? dmFocusColor : Colors.blue.shade500;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? dmGradientColors
                    : [Colors.white, Colors.grey.shade50, Colors.blue.shade50],
            stops: isDark ? const [0.0, 0.3, 0.7, 1.0] : const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Sidebar(isDarkMode: isDark),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 95,
                        left: 32,
                        right: 32,
                        bottom: 32,
                      ),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      circularProgressColor,
                                    ),
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Loading your subtasks...",
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

                        return SingleChildScrollView(
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
                                            isDark
                                                ? [
                                                  Colors.purple.shade600,
                                                  Colors.indigo.shade600,
                                                ]
                                                : [
                                                  Colors.purple.shade500,
                                                  Colors.indigo.shade500,
                                                ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark
                                                  ? Colors.purple
                                                  : Colors.purple.shade400)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.subtitles,
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
                                          "SubTask Overview",
                                          style: GoogleFonts.poppins(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                            color: headerColor,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Text(
                                          "Manage and track your assigned subtasks",
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

                              // Enhanced subtask statistics
                              _buildSubTaskStatistics(
                                controller,
                                isDark,
                                defaultTextColor,
                              ),

                              const SizedBox(height: 32),

                              // Enhanced subtask columns
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double columnSpacing = 24;
                                  int crossAxisCount =
                                      (constraints.maxWidth < 800)
                                          ? 1
                                          : ((constraints.maxWidth < 1200)
                                              ? 2
                                              : 3);
                                  bool singleColumn = crossAxisCount == 1;

                                  if (singleColumn) {
                                    return Column(
                                      children: [
                                        _buildEnhancedSubTaskColumn(
                                          context,
                                          controller,
                                          "Not Started",
                                          controller.notStartedSubTasks,
                                          isDark,
                                          columnCardBgColor,
                                          columnBorderColor,
                                          defaultTextColor,
                                          notStartedBg,
                                          notStartedTxt,
                                        ),
                                        SizedBox(height: columnSpacing),
                                        _buildEnhancedSubTaskColumn(
                                          context,
                                          controller,
                                          "In Progress",
                                          controller.inProgressSubTasks,
                                          isDark,
                                          columnCardBgColor,
                                          columnBorderColor,
                                          defaultTextColor,
                                          inProgressBg,
                                          inProgressTxt,
                                        ),
                                        SizedBox(height: columnSpacing),
                                        _buildEnhancedSubTaskColumn(
                                          context,
                                          controller,
                                          "Complete",
                                          controller.completeSubTasks,
                                          isDark,
                                          columnCardBgColor,
                                          columnBorderColor,
                                          defaultTextColor,
                                          completeBg,
                                          completeTxt,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _buildEnhancedSubTaskColumn(
                                            context,
                                            controller,
                                            "Not Started",
                                            controller.notStartedSubTasks,
                                            isDark,
                                            columnCardBgColor,
                                            columnBorderColor,
                                            defaultTextColor,
                                            notStartedBg,
                                            notStartedTxt,
                                          ),
                                        ),
                                        SizedBox(width: columnSpacing),
                                        Expanded(
                                          child: _buildEnhancedSubTaskColumn(
                                            context,
                                            controller,
                                            "In Progress",
                                            controller.inProgressSubTasks,
                                            isDark,
                                            columnCardBgColor,
                                            columnBorderColor,
                                            defaultTextColor,
                                            inProgressBg,
                                            inProgressTxt,
                                          ),
                                        ),
                                        SizedBox(width: columnSpacing),
                                        Expanded(
                                          child: _buildEnhancedSubTaskColumn(
                                            context,
                                            controller,
                                            "Complete",
                                            controller.completeSubTasks,
                                            isDark,
                                            columnCardBgColor,
                                            columnBorderColor,
                                            defaultTextColor,
                                            completeBg,
                                            completeTxt,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              Positioned(top: 0, left: 0, right: 0, child: TopBarWidget()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTaskStatistics(
    UserSubTaskController controller,
    bool isDark,
    Color defaultTextColor,
  ) {
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
            "Not Started",
            controller.notStartedSubTasks.length,
            Icons.play_circle_outline,
            isDark ? Colors.indigo.shade400 : Colors.indigo.shade500,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            "In Progress",
            controller.inProgressSubTasks.length,
            Icons.hourglass_top,
            isDark ? Colors.orange.shade400 : Colors.orange.shade500,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            "Complete",
            controller.completeSubTasks.length,
            Icons.check_circle_outline,
            isDark ? Colors.green.shade400 : Colors.green.shade500,
            isDark,
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
    bool isDark,
  ) {
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
                    count.toString(),
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

  Widget _buildEnhancedSubTaskColumn(
    BuildContext context,
    UserSubTaskController controller,
    String status,
    RxList<Map<String, dynamic>> list,
    bool isDark,
    Color columnCardBgColor,
    Color columnBorderColor,
    Color defaultTextColor,
    Color taskCardBgColor,
    Color taskCardTxtColor,
  ) {
    final scrollController = ScrollController();
    final titleColor = isDark ? dmTextColorPrimary : Colors.grey.shade800;

    String message;
    IconData emptyIcon;
    switch (status) {
      case "In Progress":
        message = "No subtasks in progress yet!";
        emptyIcon = Icons.hourglass_empty;
        break;
      case "Complete":
        message = "No completed subtasks here.";
        emptyIcon = Icons.check_circle_outline;
        break;
      default: // Not Started
        message = "No subtasks waiting to start.";
        emptyIcon = Icons.play_circle_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Enhanced column header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: taskCardBgColor.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: taskCardBgColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: taskCardBgColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: taskCardTxtColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: taskCardBgColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${list.length}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: taskCardTxtColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Enhanced subtask list container
        Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: columnCardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: columnBorderColor.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              list.isEmpty
                  ? _buildEmptyState(
                    message,
                    emptyIcon,
                    isDark,
                    defaultTextColor,
                  )
                  : Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbVisibility: MaterialStateProperty.all(true),
                        thickness: MaterialStateProperty.all(6.0),
                        radius: const Radius.circular(3),
                        thumbColor: MaterialStateProperty.all(
                          isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                        ),
                        trackColor: MaterialStateProperty.all(
                          isDark
                              ? Colors.grey.shade800.withOpacity(0.2)
                              : Colors.grey.shade200,
                        ),
                      ),
                    ),
                    child: Scrollbar(
                      controller: scrollController,
                      child: ListView.separated(
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        controller: scrollController,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final subtask = list[index];
                          return _buildEnhancedSubTaskCard(
                            context,
                            controller,
                            subtask,
                            isDark,
                            taskCardBgColor,
                            taskCardTxtColor,
                            columnBorderColor,
                          );
                        },
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    String message,
    IconData icon,
    bool isDark,
    Color defaultTextColor,
  ) {
    return Center(
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
              icon,
              size: 48,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: defaultTextColor.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Complete":
        return Icons.check_circle_outline;
      case "In Progress":
        return Icons.hourglass_top;
      default: // Not Started
        return Icons.play_circle_outline;
    }
  }

  Widget _buildEnhancedSubTaskCard(
    BuildContext context,
    UserSubTaskController controller,
    Map<String, dynamic> subtask,
    bool isDark,
    Color cardBgColor,
    Color cardTxtColor,
    Color cardBorderColor,
  ) {
    final start =
        DateTime.tryParse(subtask["startDate"]?.toString() ?? '') ??
        DateTime.now();
    final end =
        DateTime.tryParse(subtask["deadlineDate"]?.toString() ?? '') ??
        DateTime.now();
    final remaining = controller.calculateTimeRemaining(start, end);
    final remainingDays = end.difference(DateTime.now()).inDays;
    final subId = int.tryParse(subtask['id'].toString()) ?? 0;

    IconData iconData = _getStatusIcon(subtask['status']);

    final Color timeColor;
    if (subtask['status'] != "Complete") {
      if (remainingDays < 0) {
        timeColor = Colors.red.shade400;
      } else if (remainingDays <= 1) {
        timeColor = Colors.red.shade300;
      } else if (remainingDays <= 3) {
        timeColor = Colors.orange.shade300;
      } else {
        timeColor = isDark ? dmTextColorSecondary : Colors.green.shade700;
      }
    } else {
      timeColor = cardTxtColor.withOpacity(0.8);
    }

    final Color startButtonBg =
        isDark ? Colors.indigo.shade500 : Colors.indigo.shade500;
    final Color completeButtonBg =
        isDark ? Colors.green.shade500 : Colors.green.shade500;
    final Color buttonTextColor = Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [cardBgColor.withOpacity(0.8), cardBgColor.withOpacity(0.6)]
                  : [cardBgColor, cardBgColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardBorderColor.withOpacity(isDark ? 0.3 : 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cardBgColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardTxtColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData, color: cardTxtColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subtask['name'] ?? 'Unnamed SubTask',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cardTxtColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Enhanced details section
            if ((subtask['editor'] != null &&
                    subtask['editor'].toString().isNotEmpty) ||
                (subtask['note'] != null &&
                    subtask['note'].toString().isNotEmpty)) ...[
              const SizedBox(height: 12),
              if (subtask['editor'] != null &&
                  subtask['editor'].toString().isNotEmpty)
                _buildEnhancedDetail(
                  "Editor",
                  subtask['editor'],
                  cardTxtColor.withOpacity(0.9),
                ),
              if (subtask['note'] != null &&
                  subtask['note'].toString().isNotEmpty)
                _buildEnhancedDetail(
                  "Note",
                  subtask['note'],
                  cardTxtColor.withOpacity(0.9),
                  maxLines: 2,
                ),
            ],

            const SizedBox(height: 12),

            // Enhanced divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    cardTxtColor.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Enhanced date section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEnhancedSmallDetail(
                  "Start",
                  controller.formatDate(start),
                  cardTxtColor.withOpacity(0.85),
                ),
                _buildEnhancedSmallDetail(
                  "Deadline",
                  controller.formatDate(end),
                  cardTxtColor.withOpacity(0.85),
                ),
              ],
            ),

            // Enhanced time remaining section
            if (subtask['status'] != "Complete") ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: timeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: timeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: timeColor),
                    const SizedBox(width: 6),
                    Text(
                      remaining,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: timeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Enhanced action buttons
            if (subtask['status'] == "Not started")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      () => controller.updateSubTaskStatus(
                        subTaskId: subId,
                        newStatus: "In Progress",
                      ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    "Start SubTask",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: startButtonBg,
                    foregroundColor: buttonTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            if (subtask['status'] == "In Progress")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.showLinkDialog(subId),
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                  ),
                  label: Text(
                    "Add Link & Complete",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: completeButtonBg,
                    foregroundColor: buttonTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDetail(
    String label,
    String? value,
    Color color, {
    int maxLines = 1,
  }) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(_getDetailIcon(label), size: 12, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDetailIcon(String label) {
    switch (label.toLowerCase()) {
      case "editor":
        return Icons.person;
      case "note":
        return Icons.note;
      default:
        return Icons.info;
    }
  }

  Widget _buildEnhancedSmallDetail(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "$label: $value",
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
