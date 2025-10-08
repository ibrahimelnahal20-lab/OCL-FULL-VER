// lib/pages/home_page.dart

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../api/api.dart';
import '../Home/home_controller.dart';
import '../routes/routes.dart';
import '../widgets/TopBar/top_bar.dart';
import '../widgets/SideBar/sidebar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.put(HomeController());
  final ScrollController tableScrollController = ScrollController();
  final RxList<String> selectedManagers = <String>[].obs;
  final RxMap<String, TextEditingController> notes =
      <String, TextEditingController>{}.obs;

  // --- الألوان الجديدة للوضع الداكن ---
  static const Color dmCardColor = Color(0xFF161B22);
  static const Color dmSurfaceColor = Color(0xFF21262C);
  static const Color dmBorderColor = Color(0xFF30363D);
  static const Color dmScrollbarTrackColor = Color(0xFF0D1117);

  Color getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green.shade600;
      case "Delayed":
        return Colors.orange.shade700;
      case "Sent to Re-work":
        return Colors.red.shade600;
      case "On going":
        return Colors.blueAccent;
      case "Complete":
        return Colors.green.shade700;
      case "Not started":
        return Colors.grey;
      case "Cancelled":
        return Colors.red.shade900;
      case "In Progress":
        return Colors.amber.shade600;
      default:
        return Colors.grey;
    }
  }

  Widget buildFilter(
    String label,
    RxList<String> items,
    RxString selectedValue,
  ) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? dmCardColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Get.isDarkMode ? dmBorderColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue.value,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Get.isDarkMode ? Colors.white70 : Colors.black54,
              size: 20,
            ),
            style: GoogleFonts.poppins(
              color: Get.isDarkMode ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Get.isDarkMode ? dmSurfaceColor : Colors.white,
            onChanged: (val) {
              if (val != null) selectedValue.value = val;
            },
            items:
                items
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e, style: GoogleFonts.poppins()),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }

  void showManagerPopup(
    BuildContext context,
    List<String> allManagers,
    int taskId,
  ) {
    selectedManagers.clear();
    notes.clear();

    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isDarkMode ? dmCardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Select Editors",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: SizedBox(
          width: 450,
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedManagers.length < 2)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Get.isDarkMode
                              ? dmCardColor.withOpacity(0.5)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            Get.isDarkMode
                                ? dmBorderColor
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          "Choose Editor",
                          style: GoogleFonts.poppins(
                            color:
                                Get.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                        dropdownColor:
                            Get.isDarkMode ? dmSurfaceColor : Colors.white,
                        style: GoogleFonts.poppins(
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 15,
                        ),
                        value: null,
                        items:
                            allManagers
                                .where(
                                  (e) =>
                                      e != "All Editor" &&
                                      !selectedManagers.contains(e),
                                )
                                .map(
                                  (manager) => DropdownMenuItem(
                                    value: manager,
                                    child: Text(
                                      manager,
                                      style: GoogleFonts.poppins(
                                        color:
                                            Get.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null && !selectedManagers.contains(val)) {
                            selectedManagers.add(val);
                            notes[val] = TextEditingController();
                          }
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                ...selectedManagers.map(
                  (manager) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                manager,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Get.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                selectedManagers.remove(manager);
                                notes.remove(manager);
                              },
                            ),
                          ],
                        ),
                        TextField(
                          controller: notes[manager],
                          style: GoogleFonts.poppins(
                            color: Get.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: "Note for Editor",
                            labelStyle: GoogleFonts.poppins(
                              color:
                                  Get.isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                              fontSize: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    Get.isDarkMode
                                        ? Colors.white24
                                        : Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Get.theme.primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                Get.isDarkMode
                                    ? dmCardColor.withOpacity(0.5)
                                    : Colors.grey.shade100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedManagers.isNotEmpty) {
                final newProjectManager = selectedManagers.join(' - ');
                final newNoteManager = selectedManagers
                    .map((m) => "${m.trim()}: ${notes[m]?.text ?? ''}")
                    .join(', ');

                final updateData = [
                  {
                    "op": "replace",
                    "path": "/projectManager",
                    "value": newProjectManager,
                  },
                  {
                    "op": "replace",
                    "path": "/noteManager",
                    "value": newNoteManager,
                  },
                ];

                try {
                  await API.patchData("Tasks/$taskId", updateData);
                  await controller.fetchTasks();
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Managers updated successfully",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade700,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update managers",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade700,
                    colorText: Colors.white,
                  );
                }
              } else {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void showStatusPopup(BuildContext context, int taskId) {
    final RxString selectedStatus = ''.obs;
    final isDark = Get.isDarkMode;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? dmCardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Change Status",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Obx(() {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isDark ? dmCardColor.withOpacity(0.5) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? dmBorderColor : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value:
                    selectedStatus.value.isEmpty ? null : selectedStatus.value,
                hint: Text(
                  "Select new status",
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                dropdownColor: isDark ? dmSurfaceColor : Colors.white,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
                items:
                    controller.statusList
                        .where((s) => s != "All Statuses")
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status, style: GoogleFonts.poppins()),
                          ),
                        )
                        .toList(),
                onChanged: (newStatus) async {
                  if (newStatus != null) {
                    selectedStatus.value = newStatus;
                    await controller.updateTaskField(
                      taskId: taskId,
                      field: 'taskStatus',
                      newValue: newStatus,
                    );
                    Get.back();
                  }
                },
              ),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus.value.isNotEmpty) {
                await controller.updateTaskField(
                  taskId: taskId,
                  field: 'taskStatus',
                  newValue: selectedStatus.value,
                );
                Get.back();
              } else {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    final LinearGradient darkGradient = LinearGradient(
      colors: [
        const Color(0xFF0D1117),
        const Color(0xFF161B22),
        const Color(0xFF101A3D),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.5, 1.0],
    );

    final LinearGradient lightGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, Colors.blueGrey.shade50],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? darkGradient : lightGradient,
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
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 80),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                buildFilter(
                                  "Project",
                                  controller.projectList,
                                  controller.selectedProject,
                                ),
                                const SizedBox(width: 15),
                                buildFilter(
                                  "Editor",
                                  controller.employeeList,
                                  controller.selectedEmployee,
                                ),
                                const SizedBox(width: 15),
                                buildFilter(
                                  "Status",
                                  controller.statusList,
                                  controller.selectedStatus,
                                ),
                                const SizedBox(width: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? dmCardColor
                                            : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isDark
                                              ? dmBorderColor
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Obx(() {
                                    return DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value:
                                            controller.months[controller
                                                .selectedMonth
                                                .value],
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color:
                                              isDark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                          size: 20,
                                        ),
                                        style: GoogleFonts.poppins(
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        dropdownColor:
                                            isDark
                                                ? dmSurfaceColor
                                                : Colors.white,
                                        items:
                                            controller.months
                                                .map(
                                                  (m) => DropdownMenuItem(
                                                    value: m,
                                                    child: Text(
                                                      m,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                isDark
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                          ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (val) {
                                          if (val == null) return;
                                          final idx = controller.months.indexOf(
                                            val,
                                          );
                                          controller.changeMonth(idx);
                                        },
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(width: 15),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios_new,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    tableScrollController.animateTo(
                                      tableScrollController.offset - 200,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  tooltip: 'Previous Month',
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    tableScrollController.animateTo(
                                      tableScrollController.offset + 200,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  tooltip: 'Next Month',
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                    size: 20,
                                  ),
                                  tooltip: "Refresh Tasks",
                                  onPressed: () async {
                                    await controller.fetchTasks();
                                    Get.snackbar(
                                      "Refreshed",
                                      "Task list updated",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green.shade600,
                                      colorText: Colors.white,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Obx(() {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        controller.selectingMode.value =
                                            !controller.selectingMode.value;
                                        controller.selectedTaskIds.clear();
                                      },
                                      icon: Icon(
                                        controller.selectingMode.value
                                            ? Icons.cancel
                                            : Icons.select_all,
                                        size: 20,
                                      ),
                                      label: Text(
                                        controller.selectingMode.value
                                            ? "Cancel Selection"
                                            : "Select Tasks",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            controller.selectingMode.value
                                                ? Colors.redAccent
                                                : Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 5,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    if (controller.selectingMode.value)
                                      ElevatedButton.icon(
                                        onPressed:
                                            controller.selectedTaskIds.isEmpty
                                                ? null
                                                : () async {
                                                  for (var id
                                                      in controller
                                                          .selectedTaskIds) {
                                                    await controller.deleteTask(
                                                      id,
                                                    );
                                                  }
                                                  controller.selectedTaskIds
                                                      .clear();
                                                  Get.snackbar(
                                                    "Deleted",
                                                    "Selected tasks deleted successfully",
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        Colors.green.shade700,
                                                    colorText: Colors.white,
                                                  );
                                                },
                                        icon: const Icon(
                                          Icons.delete_forever,
                                          size: 20,
                                        ),
                                        label: Text(
                                          "Delete Selected",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade700,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          elevation: 5,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed:
                                      () => Get.toNamed(AppRoutes.overview),
                                  icon: const Icon(Icons.list_alt, size: 20),
                                  label: Text(
                                    "Overview SubTask",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 25),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? dmCardColor : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.2 : 0.05,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Obx(() {
                                final tasks = controller.filteredTasks;

                                if (tasks.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No tasks available",
                                      style: GoogleFonts.poppins(
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                      ),
                                    ),
                                  );
                                }

                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    dataTableTheme: DataTableThemeData(
                                      decoration: BoxDecoration(
                                        color:
                                            isDark ? dmCardColor : Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      dataRowColor:
                                          MaterialStateProperty.resolveWith<
                                            Color?
                                          >((Set<MaterialState> states) {
                                            if (states.contains(
                                              MaterialState.selected,
                                            )) {
                                              return Get.theme.primaryColor
                                                  .withOpacity(0.1);
                                            }
                                            return isDark
                                                ? dmCardColor
                                                : Colors.white;
                                          }),
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                            isDark
                                                ? dmSurfaceColor
                                                : Colors.grey[200],
                                          ),
                                      headingTextStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black87,
                                        fontSize: 14,
                                      ),
                                      dataTextStyle: GoogleFonts.poppins(
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                        fontSize: 13,
                                      ),
                                      dividerThickness: 0.5,
                                      columnSpacing: 24,
                                      horizontalMargin: 20,
                                    ),
                                    scrollbarTheme: ScrollbarThemeData(
                                      thumbColor: MaterialStateProperty.all(
                                        isDark
                                            ? Colors.grey.shade600
                                            : Colors.grey[400],
                                      ),
                                      trackColor: MaterialStateProperty.all(
                                        isDark
                                            ? dmScrollbarTrackColor.withOpacity(
                                              0.7,
                                            )
                                            : Colors.grey[100],
                                      ),
                                      thickness: MaterialStateProperty.all(8.0),
                                      radius: const Radius.circular(10),
                                    ),
                                  ),
                                  child: Scrollbar(
                                    controller: tableScrollController,
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: tableScrollController,
                                        // =======================================================
                                        // ############### START OF MODIFIED CODE ###############
                                        // =======================================================
                                        child: DataTable(
                                          columns: [
                                            if (controller.selectingMode.value)
                                              DataColumn(
                                                label: Text(
                                                  "Select",
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            DataColumn(
                                              label: Text(
                                                "id", // <-- MODIFICATION 1: Header text changed
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Task Name",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Start Date",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Deadline",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Status",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Packages",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Extras",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Project Manager",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Note from Manager",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Links",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                          // <-- MODIFICATION 2: Using asMap().entries.map() to get index
                                          rows:
                                              tasks.asMap().entries.map((
                                                entry,
                                              ) {
                                                final int index = entry.key;
                                                final task = entry.value;

                                                return DataRow(
                                                  selected: controller
                                                      .selectedTaskIds
                                                      .contains(task.taskID),
                                                  onSelectChanged:
                                                      controller
                                                              .selectingMode
                                                              .value
                                                          ? (selected) {
                                                            if (selected ==
                                                                true) {
                                                              controller
                                                                  .selectedTaskIds
                                                                  .add(
                                                                    task.taskID,
                                                                  );
                                                            } else {
                                                              controller
                                                                  .selectedTaskIds
                                                                  .remove(
                                                                    task.taskID,
                                                                  );
                                                            }
                                                          }
                                                          : null,
                                                  cells: [
                                                    if (controller
                                                        .selectingMode
                                                        .value)
                                                      DataCell(
                                                        Checkbox(
                                                          value: controller
                                                              .selectedTaskIds
                                                              .contains(
                                                                task.taskID,
                                                              ),
                                                          onChanged: (
                                                            selected,
                                                          ) {
                                                            if (selected ==
                                                                true) {
                                                              controller
                                                                  .selectedTaskIds
                                                                  .add(
                                                                    task.taskID,
                                                                  );
                                                            } else {
                                                              controller
                                                                  .selectedTaskIds
                                                                  .remove(
                                                                    task.taskID,
                                                                  );
                                                            }
                                                          },
                                                          activeColor:
                                                              Get
                                                                  .theme
                                                                  .primaryColor,
                                                        ),
                                                      ),
                                                    DataCell(
                                                      Text(
                                                        // <-- MODIFICATION 3: Displaying index + 1
                                                        (index + 1).toString(),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(task.taskName),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        DateFormat(
                                                          'dd MMM yy',
                                                        ).format(
                                                          DateTime.parse(
                                                            task.taskStartDate,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          Text(
                                                            DateFormat(
                                                              'dd MMM yy',
                                                            ).format(
                                                              DateTime.parse(
                                                                task.taskDeadLine,
                                                              ),
                                                            ),
                                                          ),
                                                          if (controller
                                                                  .userType
                                                                  .value ==
                                                              "admin")
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .calendar_today,
                                                                size: 16,
                                                                color:
                                                                    isDark
                                                                        ? Colors
                                                                            .white70
                                                                        : Colors
                                                                            .black54,
                                                              ),
                                                              tooltip:
                                                                  "Edit Deadline",
                                                              onPressed:
                                                                  () => controller
                                                                      .showDeadlineDialog(
                                                                        context,
                                                                        task.taskID,
                                                                        task.taskDeadLine,
                                                                      ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 6,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: getStatusColor(
                                                                task.taskStatus,
                                                              ).withOpacity(
                                                                0.2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              task.taskStatus,
                                                              style: GoogleFonts.poppins(
                                                                color: getStatusColor(
                                                                  task.taskStatus,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                          if (controller
                                                                  .userType
                                                                  .value ==
                                                              "admin")
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.edit,
                                                                size: 16,
                                                                color:
                                                                    isDark
                                                                        ? Colors
                                                                            .white70
                                                                        : Colors
                                                                            .black54,
                                                              ),
                                                              onPressed:
                                                                  () => showStatusPopup(
                                                                    context,
                                                                    task.taskID,
                                                                  ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          Text(
                                                            task.packages,
                                                            style:
                                                                GoogleFonts.poppins(),
                                                          ),
                                                          if (controller
                                                                  .userType
                                                                  .value ==
                                                              "admin")
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.edit,
                                                                size: 16,
                                                                color:
                                                                    isDark
                                                                        ? Colors
                                                                            .white70
                                                                        : Colors
                                                                            .black54,
                                                              ),
                                                              tooltip:
                                                                  "Edit Package",
                                                              onPressed: () async {
                                                                RxString
                                                                selectedPackage =
                                                                    task
                                                                        .packages
                                                                        .obs;
                                                                await Get.defaultDialog(
                                                                  title:
                                                                      "Edit Package",
                                                                  titleStyle: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        isDark
                                                                            ? Colors.white
                                                                            : Colors.black,
                                                                  ),
                                                                  backgroundColor:
                                                                      isDark
                                                                          ? dmCardColor
                                                                          : Colors
                                                                              .white,
                                                                  content: Obx(
                                                                    () => Container(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            5,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            isDark
                                                                                ? dmCardColor.withOpacity(
                                                                                  0.5,
                                                                                )
                                                                                : Colors.grey.shade100,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                        border: Border.all(
                                                                          color:
                                                                              isDark
                                                                                  ? dmBorderColor
                                                                                  : Colors.grey.shade300,
                                                                        ),
                                                                      ),
                                                                      child: DropdownButtonHideUnderline(
                                                                        child: DropdownButton<
                                                                          String
                                                                        >(
                                                                          isExpanded:
                                                                              true,
                                                                          value:
                                                                              selectedPackage.value.isEmpty
                                                                                  ? null
                                                                                  : selectedPackage.value,
                                                                          dropdownColor:
                                                                              isDark
                                                                                  ? dmSurfaceColor
                                                                                  : Colors.white,
                                                                          style: GoogleFonts.poppins(
                                                                            color:
                                                                                isDark
                                                                                    ? Colors.white
                                                                                    : Colors.black,
                                                                            fontSize:
                                                                                15,
                                                                          ),
                                                                          hint: Text(
                                                                            "Select Package",
                                                                            style: GoogleFonts.poppins(
                                                                              color:
                                                                                  isDark
                                                                                      ? Colors.white70
                                                                                      : Colors.black87,
                                                                              fontSize:
                                                                                  15,
                                                                            ),
                                                                          ),
                                                                          items:
                                                                              controller.packageNames.map((
                                                                                pkgName,
                                                                              ) {
                                                                                return DropdownMenuItem(
                                                                                  value:
                                                                                      pkgName,
                                                                                  child: Text(
                                                                                    pkgName,
                                                                                    style:
                                                                                        GoogleFonts.poppins(),
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                          onChanged: (
                                                                            newVal,
                                                                          ) {
                                                                            if (newVal !=
                                                                                null) {
                                                                              selectedPackage.value = newVal;
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  confirm: ElevatedButton(
                                                                    onPressed: () async {
                                                                      await controller.updateTaskPackages(
                                                                        taskId:
                                                                            task.taskID,
                                                                        newPackages:
                                                                            selectedPackage.value,
                                                                      );
                                                                      Get.back();
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Get
                                                                              .theme
                                                                              .primaryColor,
                                                                      foregroundColor:
                                                                          Colors
                                                                              .white,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                      ),
                                                                      elevation:
                                                                          5,
                                                                      textStyle: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        const Text(
                                                                          "Save",
                                                                        ),
                                                                  ),
                                                                  cancel: TextButton(
                                                                    onPressed:
                                                                        () =>
                                                                            Get.back(),
                                                                    child: Text(
                                                                      "Cancel",
                                                                      style: GoogleFonts.poppins(
                                                                        color:
                                                                            Colors.redAccent,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              task.extras,
                                                            ),
                                                          ),
                                                          if (controller
                                                                  .userType
                                                                  .value ==
                                                              "admin")
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.edit,
                                                                size: 16,
                                                                color:
                                                                    isDark
                                                                        ? Colors
                                                                            .white70
                                                                        : Colors
                                                                            .black54,
                                                              ),
                                                              onPressed: () {
                                                                final RxString
                                                                selectedExtra =
                                                                    task
                                                                        .extras
                                                                        .obs;
                                                                Get.dialog(
                                                                  AlertDialog(
                                                                    backgroundColor:
                                                                        isDark
                                                                            ? dmCardColor
                                                                            : Colors.white,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            20,
                                                                          ),
                                                                    ),
                                                                    title: Text(
                                                                      "Select Extras",
                                                                      style: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            20,
                                                                        color:
                                                                            isDark
                                                                                ? Colors.white
                                                                                : Colors.black,
                                                                      ),
                                                                    ),
                                                                    content: Obx(() {
                                                                      return Container(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              5,
                                                                        ),
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              isDark
                                                                                  ? dmCardColor.withOpacity(
                                                                                    0.5,
                                                                                  )
                                                                                  : Colors.grey.shade100,
                                                                          borderRadius: BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                          border: Border.all(
                                                                            color:
                                                                                isDark
                                                                                    ? dmBorderColor
                                                                                    : Colors.grey.shade300,
                                                                          ),
                                                                        ),
                                                                        child: DropdownButtonHideUnderline(
                                                                          child: DropdownButton<
                                                                            String
                                                                          >(
                                                                            isExpanded:
                                                                                true,
                                                                            value:
                                                                                selectedExtra.value.isEmpty
                                                                                    ? null
                                                                                    : selectedExtra.value,
                                                                            hint: Text(
                                                                              "Choose extra type",
                                                                              style: GoogleFonts.poppins(
                                                                                color:
                                                                                    isDark
                                                                                        ? Colors.white70
                                                                                        : Colors.black87,
                                                                                fontSize:
                                                                                    15,
                                                                              ),
                                                                            ),
                                                                            dropdownColor:
                                                                                isDark
                                                                                    ? dmSurfaceColor
                                                                                    : Colors.white,
                                                                            style: GoogleFonts.poppins(
                                                                              color:
                                                                                  isDark
                                                                                      ? Colors.white
                                                                                      : Colors.black,
                                                                              fontSize:
                                                                                  15,
                                                                            ),
                                                                            items:
                                                                                [
                                                                                  "Documentary",
                                                                                  "Reel",
                                                                                  "Highlight",
                                                                                  "Stories",
                                                                                  "drone",
                                                                                ].map((
                                                                                  extra,
                                                                                ) {
                                                                                  return DropdownMenuItem(
                                                                                    value:
                                                                                        extra,
                                                                                    child: Text(
                                                                                      extra,
                                                                                      style:
                                                                                          GoogleFonts.poppins(),
                                                                                    ),
                                                                                  );
                                                                                }).toList(),
                                                                            onChanged: (
                                                                              val,
                                                                            ) {
                                                                              if (val !=
                                                                                  null) {
                                                                                selectedExtra.value = val;
                                                                              }
                                                                            },
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () =>
                                                                                Get.back(),
                                                                        child: Text(
                                                                          "Cancel",
                                                                          style: GoogleFonts.poppins(
                                                                            color:
                                                                                Colors.redAccent,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontSize:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        onPressed: () async {
                                                                          await controller.updateTaskField(
                                                                            taskId:
                                                                                task.taskID,
                                                                            field:
                                                                                "extras",
                                                                            newValue:
                                                                                selectedExtra.value,
                                                                          );
                                                                          Get.back();
                                                                        },
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              Get.theme.primaryColor,
                                                                          foregroundColor:
                                                                              Colors.white,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                          ),
                                                                          elevation:
                                                                              5,
                                                                          textStyle: GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontSize:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                        child: const Text(
                                                                          "Save",
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          Text(
                                                            task.projectManager,
                                                            style:
                                                                GoogleFonts.poppins(),
                                                          ),
                                                          if (controller
                                                                  .userType
                                                                  .value ==
                                                              "admin")
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.edit,
                                                                size: 16,
                                                                color:
                                                                    isDark
                                                                        ? Colors
                                                                            .white70
                                                                        : Colors
                                                                            .black54,
                                                              ),
                                                              onPressed:
                                                                  () => showManagerPopup(
                                                                    context,
                                                                    controller
                                                                        .employeeList,
                                                                    task.taskID,
                                                                  ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        task.noteManager,
                                                        style:
                                                            GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                              maxWidth: 250,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children:
                                                              task.links.split(' - ').take(2).map((
                                                                link,
                                                              ) {
                                                                final trimmed =
                                                                    link.trim();
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            3,
                                                                      ),
                                                                  child: Row(
                                                                    children: [
                                                                      if (controller
                                                                              .userType
                                                                              .value ==
                                                                          "admin")
                                                                        IconButton(
                                                                          onPressed:
                                                                              () => controller.showLinkDialog(
                                                                                task.taskID,
                                                                              ),
                                                                          icon: Icon(
                                                                            Icons.edit,
                                                                            size:
                                                                                16,
                                                                            color:
                                                                                isDark
                                                                                    ? Colors.white70
                                                                                    : Colors.black54,
                                                                          ),
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                          constraints:
                                                                              const BoxConstraints(),
                                                                          tooltip:
                                                                              "Edit Link",
                                                                        ),
                                                                      const SizedBox(
                                                                        width:
                                                                            6,
                                                                      ),
                                                                      Expanded(
                                                                        child: Text(
                                                                          trimmed,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                isDark
                                                                                    ? Colors.white
                                                                                    : Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            6,
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap: () {
                                                                          Clipboard.setData(
                                                                            ClipboardData(
                                                                              text:
                                                                                  trimmed,
                                                                            ),
                                                                          );
                                                                          Get.snackbar(
                                                                            "Copied",
                                                                            "Link copied to clipboard",
                                                                            snackPosition:
                                                                                SnackPosition.BOTTOM,
                                                                            backgroundColor:
                                                                                isDark
                                                                                    ? dmSurfaceColor
                                                                                    : Colors.grey[300],
                                                                            colorText:
                                                                                isDark
                                                                                    ? Colors.white
                                                                                    : Colors.black,
                                                                          );
                                                                        },
                                                                        child: Icon(
                                                                          Icons
                                                                              .copy,
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              isDark
                                                                                  ? Colors.white70
                                                                                  : Colors.black54,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                        ),
                                        // =======================================================
                                        // ################ END OF MODIFIED CODE ################
                                        // =======================================================
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
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
  }
}
