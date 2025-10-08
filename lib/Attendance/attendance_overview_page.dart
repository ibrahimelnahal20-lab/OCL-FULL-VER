// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ocl2/Theme/theme_controller.dart';
import 'package:ocl2/widgets/SideBar/sidebar.dart';
import 'package:ocl2/widgets/TopBar/top_bar.dart';
import 'attendance_overview_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceOverviewPage extends StatelessWidget {
  const AttendanceOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceOverviewController controller = Get.put(
      AttendanceOverviewController(),
    );
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      themeController.currentThemeMode.value;
      final isCurrentlyDark = themeController.isDarkMode;
      final theme = themeController.activeThemeData;

      return Scaffold(
        backgroundColor:
            isCurrentlyDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Sidebar(isDarkMode: isCurrentlyDark),
                  Expanded(
                    child: _PageContent(
                      controller: controller,
                      theme: theme,
                      isDark: isCurrentlyDark,
                    ),
                  ),
                ],
              ),
              TopBarWidget(),
            ],
          ),
        ),
      );
    });
  }
}

class _PageContent extends StatefulWidget {
  final AttendanceOverviewController controller;
  final ThemeData theme;
  final bool isDark;

  const _PageContent({
    required this.controller,
    required this.theme,
    required this.isDark,
  });

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent> {
  late TimeOfDay checkInTime;
  late TimeOfDay checkOutTime;
  bool loadingTimes = true;

  @override
  void initState() {
    super.initState();
    _loadReferenceTimes();
  }

  Future<void> _loadReferenceTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final checkInStr = prefs.getString('checkInTime');
    final checkOutStr = prefs.getString('checkOutTime');
    setState(() {
      checkInTime =
          checkInStr != null && checkInStr.contains(':')
              ? TimeOfDay(
                hour: int.parse(checkInStr.split(':')[0]),
                minute: int.parse(checkInStr.split(':')[1]),
              )
              : const TimeOfDay(hour: 8, minute: 0);
      checkOutTime =
          checkOutStr != null && checkOutStr.contains(':')
              ? TimeOfDay(
                hour: int.parse(checkOutStr.split(':')[0]),
                minute: int.parse(checkOutStr.split(':')[1]),
              )
              : const TimeOfDay(hour: 17, minute: 0);
      loadingTimes = false;
    });
  }

  Future<void> _saveReferenceTimes(TimeOfDay inTime, TimeOfDay outTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'checkInTime',
      '${inTime.hour.toString().padLeft(2, '0')}:${inTime.minute.toString().padLeft(2, '0')}',
    );
    await prefs.setString(
      'checkOutTime',
      '${outTime.hour.toString().padLeft(2, '0')}:${outTime.minute.toString().padLeft(2, '0')}',
    );
    setState(() {
      checkInTime = inTime;
      checkOutTime = outTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingTimes) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 110, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildReferenceTimesLocal(),
          const SizedBox(height: 24),
          _buildFilterBar(context),
          const SizedBox(height: 24),
          _buildMainCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attendance Overview",
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: widget.theme.colorScheme.onBackground,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Monitor and analyze employee attendance patterns",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: widget.theme.colorScheme.onBackground.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Obx(() {
      final totalEmployees = widget.controller.displayedAttendanceList.length;
      final presentCount =
          widget.controller.displayedAttendanceList
              .where(
                (record) =>
                    record['status'] == 'On Time' ||
                    record['status'] == 'Early Arrival',
              )
              .length;
      final lateCount =
          widget.controller.displayedAttendanceList
              .where((record) => record['status'] == 'Late Arrival')
              .length;
      final absentCount =
          widget.controller.displayedAttendanceList
              .where((record) => record['status'] == 'Absent')
              .length;

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            // Small screen: horizontal scroll
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: _buildStatCard(
                      "Total Employees",
                      totalEmployees.toString(),
                      Icons.people_alt_rounded,
                      Colors.blue,
                      widget.isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 220,
                    child: _buildStatCard(
                      "Present",
                      presentCount.toString(),
                      Icons.check_circle_rounded,
                      Colors.green,
                      widget.isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 220,
                    child: _buildStatCard(
                      "Late",
                      lateCount.toString(),
                      Icons.schedule_rounded,
                      Colors.orange,
                      widget.isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 220,
                    child: _buildStatCard(
                      "Absent",
                      absentCount.toString(),
                      Icons.cancel_rounded,
                      Colors.red,
                      widget.isDark,
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Large screen: normal row
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Total Employees",
                    totalEmployees.toString(),
                    Icons.people_alt_rounded,
                    Colors.blue,
                    widget.isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    "Present",
                    presentCount.toString(),
                    Icons.check_circle_rounded,
                    Colors.green,
                    widget.isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    "Late",
                    lateCount.toString(),
                    Icons.schedule_rounded,
                    Colors.orange,
                    widget.isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    "Absent",
                    absentCount.toString(),
                    Icons.cancel_rounded,
                    Colors.red,
                    widget.isDark,
                  ),
                ),
              ],
            );
          }
        },
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [color.withOpacity(0.2), color.withOpacity(0.1)]
                  : [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: color.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: widget.theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: widget.theme.colorScheme.onBackground.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildFilterControls(context),
                const SizedBox(height: 24),
                _buildAttendanceTable(),
                const SizedBox(height: 24),
                _buildPaginationControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Attendance Records",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.colorScheme.onBackground,
                ),
              ),
              Text(
                "Detailed view of all attendance entries",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: widget.theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmall = constraints.maxWidth < 750;
        return isSmall
            ? Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDatePicker(context)),
                    const SizedBox(width: 12),
                    // Removed filter button
                  ],
                ),
              ],
            )
            : Row(
              children: [
                Expanded(flex: 2, child: _buildSearchField()),
                const SizedBox(width: 20),
                Expanded(flex: 1, child: _buildDatePicker(context)),
                const SizedBox(width: 20),
                // Removed filter button
              ],
            );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller.searchController,
        style: GoogleFonts.poppins(
          color: widget.theme.colorScheme.onSurface,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name, role, status...',
          hintStyle: GoogleFonts.poppins(
            color: widget.theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.search_rounded,
              color: widget.theme.colorScheme.primary,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: widget.theme.scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => widget.controller.selectDate(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: widget.theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: widget.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.controller.formattedSelectedDate,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: widget.theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return Obx(() {
      if (widget.controller.isLoading.value) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
            color: widget.theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading attendance data..."),
              ],
            ),
          ),
        );
      }

      if (widget.controller.error.value != null) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${widget.controller.error.value}',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (widget.controller.displayedAttendanceList.isEmpty) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: widget.theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  color: widget.theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "No data found for the selected filters.",
                  style: TextStyle(
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Wrap DataTable in horizontal scroll view to prevent overflow
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: const BoxConstraints(minWidth: 900),
          decoration: BoxDecoration(
            color: widget.theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DataTable(
              sortColumnIndex: widget.controller.sortColumnIndex.value,
              sortAscending: widget.controller.isAscending.value,
              headingRowHeight: 64,
              dataRowMaxHeight: 72,
              dividerThickness: 1,
              columnSpacing: 24,
              headingTextStyle: GoogleFonts.poppins(
                color: widget.theme.colorScheme.onSurface.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              dataTextStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: widget.theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              columns: [
                DataColumn(
                  label: _buildColumnHeader(
                    'No.',
                    Icons.format_list_numbered_rounded,
                  ),
                ),
                DataColumn(
                  label: _buildColumnHeader('Employee', Icons.person_rounded),
                  onSort: (index, asc) => widget.controller.sortData(index - 1),
                ),
                DataColumn(
                  label: _buildColumnHeader(
                    'Department',
                    Icons.business_rounded,
                  ),
                  onSort: (index, asc) => widget.controller.sortData(index - 1),
                ),
                DataColumn(
                  label: _buildColumnHeader(
                    'Date',
                    Icons.calendar_today_rounded,
                  ),
                  onSort: (index, asc) => widget.controller.sortData(index - 1),
                ),
                DataColumn(
                  label: _buildColumnHeader('Status', Icons.info_rounded),
                  onSort: (index, asc) => widget.controller.sortData(index - 1),
                ),
                DataColumn(
                  label: _buildColumnHeader('Check-in', Icons.login_rounded),
                  onSort: (index, asc) => widget.controller.sortData(index - 1),
                ),
                DataColumn(
                  label: _buildColumnHeader('Check-out', Icons.logout_rounded),
                  onSort: (index, asc) => widget.controller.sortData(index - 1),
                ),
                DataColumn(
                  label: _buildColumnHeader(
                    'Work Hours',
                    Icons.access_time_rounded,
                  ),
                  onSort: (index, asc) => widget.controller.sortData(index - 1),
                ),
                DataColumn(
                  label: _buildColumnHeader(
                    'Late/Early Time',
                    Icons.timer_rounded,
                  ),
                ),
              ],
              rows: List.generate(
                widget.controller.displayedAttendanceList.length,
                (index) {
                  final record =
                      widget.controller.displayedAttendanceList[index];
                  final status = record['status'] as String? ?? 'N/A';
                  final statusEn = status;

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>((states) {
                      final baseColor = _getRowColorByStatus(statusEn);
                      if (states.contains(MaterialState.hovered)) {
                        return widget.theme.colorScheme.primary.withOpacity(
                          0.08,
                        );
                      }
                      return baseColor?.withOpacity(0.05);
                    }),
                    cells: [
                      DataCell(_buildIndexCell(index + 1)),
                      DataCell(
                        _buildEmployeeCell(
                          record['employee']?.toString() ?? 'N/A',
                        ),
                      ),
                      DataCell(Text(record['department']?.toString() ?? 'N/A')),
                      DataCell(
                        _buildDateCell(record['date']?.toString() ?? 'N/A'),
                      ),
                      DataCell(_buildStatusChip(statusEn)),
                      DataCell(
                        _buildTimeCell(
                          record['check_in']?.toString() ?? '--:--',
                        ),
                      ),
                      DataCell(
                        _buildTimeCell(
                          record['check_out']?.toString() ?? '--:--',
                        ),
                      ),
                      DataCell(
                        _buildWorkHoursCell(
                          record['work_hours']?.toString() ?? 'N/A',
                        ),
                      ),
                      DataCell(
                        _buildLateEarlyTimeCell(
                          record['late_early_time']?.toString() ?? 'N/A',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildColumnHeader(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: widget.theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildIndexCell(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        index.toString(),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: widget.theme.colorScheme.primary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmployeeCell(String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: widget.theme.colorScheme.primary.withOpacity(0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: widget.theme.colorScheme.primary,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCell(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: widget.theme.dividerColor.withOpacity(0.3)),
      ),
      child: Text(
        date,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTimeCell(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        time,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: widget.theme.colorScheme.secondary,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildWorkHoursCell(String hours) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        hours,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor, fgColor;
    IconData icon;

    switch (status) {
      case 'Absent':
        bgColor =
            widget.isDark
                ? Colors.red.shade900.withOpacity(0.3)
                : Colors.red.shade50;
        fgColor = widget.isDark ? Colors.red.shade300 : Colors.red.shade700;
        icon = Icons.cancel_rounded;
        break;
      case 'Late Arrival':
        bgColor =
            widget.isDark
                ? Colors.orange.shade900.withOpacity(0.3)
                : Colors.orange.shade50;
        fgColor =
            widget.isDark ? Colors.orange.shade300 : Colors.orange.shade700;
        icon = Icons.schedule_rounded;
        break;
      case 'Early Arrival':
        bgColor =
            widget.isDark
                ? Colors.blue.shade900.withOpacity(0.3)
                : Colors.blue.shade50;
        fgColor = widget.isDark ? Colors.blue.shade300 : Colors.blue.shade700;
        icon = Icons.trending_up_rounded;
        break;
      case 'On Time':
        bgColor =
            widget.isDark
                ? Colors.green.shade900.withOpacity(0.3)
                : Colors.green.shade50;
        fgColor = widget.isDark ? Colors.green.shade300 : Colors.green.shade700;
        icon = Icons.check_circle_rounded;
        break;
      default:
        bgColor = widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100;
        fgColor = widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700;
        icon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fgColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fgColor),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: fgColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLateEarlyTimeCell(String time) {
    if (time == 'N/A' || time.isEmpty) {
      return Text(
        '--',
        style: TextStyle(
          color: widget.theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      );
    }

    final isLate = time.contains('Late');
    final isEarly = time.contains('Early');
    final isOnTime = time == 'On Time';

    Color bgColor;
    Color textColor;

    if (isLate) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    } else if (isEarly) {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    } else if (isOnTime) {
      bgColor = Colors.blue.shade100;
      textColor = Colors.blue.shade800;
    } else {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        time,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: textColor,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.theme.dividerColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Rows per page:",
                  style: GoogleFonts.poppins(
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: widget.controller.rowsPerPage,
                  items:
                      [10, 20, 50, 100]
                          .map(
                            (v) => DropdownMenuItem<int>(
                              value: v,
                              child: Text(v.toString()),
                            ),
                          )
                          .toList(),
                  onChanged: (v) {
                    if (v != null) widget.controller.setRowsPerPage(v);
                  },
                ),
              ],
            ),
            Text(
              "Showing page ${widget.controller.currentPage.value} of ${widget.controller.totalPages}",
              style: GoogleFonts.poppins(
                color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                _buildPaginationButton(
                  "Previous",
                  Icons.arrow_back_ios_rounded,
                  widget.controller.currentPage.value > 1
                      ? widget.controller.previousPage
                      : null,
                  isFirst: true,
                ),
                const SizedBox(width: 12),
                _buildPaginationButton(
                  "Next",
                  Icons.arrow_forward_ios_rounded,
                  widget.controller.currentPage.value <
                          widget.controller.totalPages
                      ? widget.controller.nextPage
                      : null,
                  isFirst: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationButton(
    String text,
    IconData icon,
    VoidCallback? onPressed, {
    required bool isFirst,
  }) {
    final isEnabled = onPressed != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient:
            isEnabled
                ? LinearGradient(
                  colors: [
                    widget.theme.colorScheme.primary,
                    widget.theme.colorScheme.primary.withOpacity(0.8),
                  ],
                )
                : null,
        color:
            isEnabled
                ? null
                : widget.theme.colorScheme.onSurface.withOpacity(0.1),
        boxShadow:
            isEnabled
                ? [
                  BoxShadow(
                    color: widget.theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isFirst) ...[
                  Icon(
                    icon,
                    size: 16,
                    color:
                        isEnabled
                            ? Colors.white
                            : widget.theme.colorScheme.onSurface.withOpacity(
                              0.5,
                            ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color:
                        isEnabled
                            ? Colors.white
                            : widget.theme.colorScheme.onSurface.withOpacity(
                              0.5,
                            ),
                    fontSize: 14,
                  ),
                ),
                if (isFirst) ...[
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    size: 16,
                    color:
                        isEnabled
                            ? Colors.white
                            : widget.theme.colorScheme.onSurface.withOpacity(
                              0.5,
                            ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceTimesLocal() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Small screen: column
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    widget.isDark
                        ? [
                          Colors.blue.shade900.withOpacity(0.3),
                          Colors.blue.shade800.withOpacity(0.2),
                        ]
                        : [
                          Colors.blue.shade50,
                          Colors.blue.shade100.withOpacity(0.3),
                        ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Reference Times',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    _buildEditTimeButtonLocal(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRefTimeCard(
                  'Reference Check-in',
                  checkInTime.format(context),
                ),
                const SizedBox(height: 12),
                _buildRefTimeCard(
                  'Reference Check-out',
                  checkOutTime.format(context),
                ),
              ],
            ),
          );
        } else {
          // Large screen: row
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    widget.isDark
                        ? [
                          Colors.blue.shade900.withOpacity(0.3),
                          Colors.blue.shade800.withOpacity(0.2),
                        ]
                        : [
                          Colors.blue.shade50,
                          Colors.blue.shade100.withOpacity(0.3),
                        ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildRefTimeCard(
                          'Reference Check-in',
                          checkInTime.format(context),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildRefTimeCard(
                          'Reference Check-out',
                          checkOutTime.format(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildEditTimeButtonLocal(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildRefTimeCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTimeButtonLocal() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showTimeSettingsDialogLocal,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Edit Times',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTimeSettingsDialogLocal() {
    showDialog(
      context: context,
      builder:
          (context) => _TimeSettingsDialogLocal(
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            theme: widget.theme,
            isDark: widget.isDark,
            onSave: (inTime, outTime) async {
              await _saveReferenceTimes(inTime, outTime);
              Get.snackbar(
                'Success',
                'Reference times updated successfully!',
                backgroundColor: Colors.green.withOpacity(0.1),
                colorText: Colors.green.shade700,
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 2),
              );
            },
          ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Obx(() {
      final theme = widget.theme;
      final controller = widget.controller;
      final filters = <Widget>[];

      // Search field
      filters.add(
        SizedBox(
          width: 220,
          child: TextField(
            controller: controller.searchController,
            style: GoogleFonts.poppins(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name, role, status...',
              hintStyle: GoogleFonts.poppins(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
            ),
          ),
        ),
      );

      // Date range picker
      filters.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              controller.filterDateRange.value != null
                  ? '${controller.filterDateRange.value!.start.toLocal().toString().split(' ')[0]} - ${controller.filterDateRange.value!.end.toLocal().toString().split(' ')[0]}'
                  : controller.formattedSelectedDate,
            ),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: controller.filterDateRange.value,
              );
              if (picked != null) {
                controller.applyAdvancedFilters(dateRange: picked);
              }
            },
          ),
        ),
      );

      // Status filter
      filters.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButton<String>(
            value: controller.filterStatus.value ?? '',
            items:
                ['', 'On Time', 'Late Arrival', 'Early Arrival', 'Absent']
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e.isEmpty ? 'Status' : e),
                      ),
                    )
                    .toList(),
            onChanged:
                (val) => controller.applyAdvancedFilters(
                  status: val != '' ? val : null,
                ),
            underline: Container(),
            style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
            dropdownColor: theme.cardColor,
          ),
        ),
      );

      // Department filter (dropdown)
      filters.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButton<String>(
            value:
                controller.uniqueJobTitles.contains(
                      controller.filterDepartment.value,
                    )
                    ? controller.filterDepartment.value
                    : '',
            items:
                ['']
                    .followedBy(controller.uniqueJobTitles)
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e.isEmpty ? 'Department' : e),
                      ),
                    )
                    .toList(),
            onChanged:
                (val) => controller.applyAdvancedFilters(
                  department: val != '' ? val : null,
                ),
            underline: Container(),
            style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
            dropdownColor: theme.cardColor,
          ),
        ),
      );

      // Filter chips for active filters
      final chips = <Widget>[];
      if (controller.filterStatus.value != null &&
          controller.filterStatus.value!.isNotEmpty) {
        chips.add(
          _buildFilterChip(
            'Status: ${controller.filterStatus.value}',
            () => controller.applyAdvancedFilters(status: null),
          ),
        );
      }
      if (controller.filterDepartment.value != null &&
          controller.filterDepartment.value!.isNotEmpty) {
        chips.add(
          _buildFilterChip(
            'Department: ${controller.filterDepartment.value}',
            () => controller.applyAdvancedFilters(department: null),
          ),
        );
      }
      if (controller.filterDateRange.value != null) {
        chips.add(
          _buildFilterChip(
            'Date: ${controller.filterDateRange.value!.start.toLocal().toString().split(' ')[0]} - ${controller.filterDateRange.value!.end.toLocal().toString().split(' ')[0]}',
            () => controller.applyAdvancedFilters(dateRange: null),
          ),
        );
      }

      // Clear all button
      if (chips.isNotEmpty) {
        chips.add(
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: OutlinedButton(
              onPressed: controller.clearAdvancedFilters,
              child: const Text('Clear All'),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: filters),
          ),
          if (chips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(spacing: 8, children: chips),
            ),
        ],
      );
    });
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: widget.theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

Color? _getRowColorByStatus(String status) {
  switch (status) {
    case 'Absent':
      return Colors.red;
    case 'Late Arrival':
      return Colors.orange;
    case 'Early Arrival':
      return Colors.blue;
    case 'On Time':
      return Colors.green;
    default:
      return null;
  }
}

class _AdvancedFilterDialog extends StatefulWidget {
  final AttendanceOverviewController controller;
  final ThemeData theme;
  const _AdvancedFilterDialog({required this.controller, required this.theme});

  @override
  State<_AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends State<_AdvancedFilterDialog> {
  late TextEditingController employeeController;
  late TextEditingController departmentController;
  String? status;
  DateTimeRange? dateRange;

  @override
  void initState() {
    super.initState();
    employeeController = TextEditingController();
    departmentController = TextEditingController();
  }

  @override
  void dispose() {
    employeeController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Advanced Filters',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: employeeController,
              decoration: InputDecoration(
                labelText: 'Employee Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: departmentController,
              decoration: InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: status ?? '',
              items:
                  ['', 'On Time', 'Late Arrival', 'Early Arrival', 'Absent']
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e.isEmpty ? 'Any' : e),
                        ),
                      )
                      .toList(),
              onChanged:
                  (val) => setState(() => status = (val != '' ? val : null)),
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      dateRange == null
                          ? 'Select Date Range'
                          : '${dateRange!.start.toLocal().toString().split(' ')[0]} - ${dateRange!.end.toLocal().toString().split(' ')[0]}',
                    ),
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDateRange: dateRange,
                      );
                      if (picked != null) setState(() => dateRange = picked);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Apply filters
            widget.controller.applyAdvancedFilters(
              employee: employeeController.text,
              department: departmentController.text,
              status: status,
              dateRange: dateRange,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _TimeSettingsDialogLocal extends StatefulWidget {
  final TimeOfDay checkInTime;
  final TimeOfDay checkOutTime;
  final ThemeData theme;
  final bool isDark;
  final Future<void> Function(TimeOfDay, TimeOfDay) onSave;

  const _TimeSettingsDialogLocal({
    required this.checkInTime,
    required this.checkOutTime,
    required this.theme,
    required this.isDark,
    required this.onSave,
  });

  @override
  State<_TimeSettingsDialogLocal> createState() =>
      _TimeSettingsDialogLocalState();
}

class _TimeSettingsDialogLocalState extends State<_TimeSettingsDialogLocal> {
  late TimeOfDay checkInTime;
  late TimeOfDay checkOutTime;

  @override
  void initState() {
    super.initState();
    checkInTime = widget.checkInTime;
    checkOutTime = widget.checkOutTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Set Reference Times',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _buildTimeSettingCard(
            'Check-in Time',
            checkInTime.format(context),
            Icons.login_rounded,
            Colors.green,
            () async {
              final time = await showTimePicker(
                context: context,
                initialTime: checkInTime,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(colorScheme: widget.theme.colorScheme),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() => checkInTime = time);
              }
            },
          ),
          const SizedBox(height: 16),
          _buildTimeSettingCard(
            'Check-out Time',
            checkOutTime.format(context),
            Icons.logout_rounded,
            Colors.orange,
            () async {
              final time = await showTimePicker(
                context: context,
                initialTime: checkOutTime,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(colorScheme: widget.theme.colorScheme),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() => checkOutTime = time);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await widget.onSave(checkInTime, checkOutTime);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSettingCard(
    String title,
    String time,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              widget.isDark
                  ? [color.withOpacity(0.2), color.withOpacity(0.1)]
                  : [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.theme.colorScheme.onSurface.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_rounded,
                  color: color.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
