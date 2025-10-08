// lib/pages/sub_task_overview_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'over_sub_task_controller.dart'; // Ensure this path is correct
import 'package:ocl2/widgets/TopBar/top_bar.dart'; // Ensure this path is correct
import 'package:ocl2/widgets/SideBar/sidebar.dart'; // Ensure this path is correct

class SubTaskOverviewPage extends StatelessWidget {
  SubTaskOverviewPage({super.key});

  final OverSubTaskController controller = Get.put(OverSubTaskController());
  final ScrollController tableScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  // --- Dark Mode Color Definitions ---
  static const List<Color> dmGradientColors = [
    Color(0xFF0D1117),
    Color(0xFF161B22),
    Color(0xFF101A3D),
  ];
  static const Color dmCardColor = Color(0xFF161B22);
  static const Color dmSurfaceColor = Color(0xFF21262C);
  static const Color dmBorderColor = Color(0xFF30363D);
  static const Color dmTextColorPrimary = Colors.white;
  static const Color dmTextColorSecondary = Colors.white70;
  static const Color dmIconColor = Colors.white70;
  static const Color dmScrollbarTrackColor = Color(0xFF0D1117);
  static const Color dmScrollbarThumbColor = Colors.grey;


  Color getStatusColor(String status) {
    switch (status) {
      case "Complete":
        return Colors.green.shade700;
      case "On Hold":
        return Colors.orange.shade700;
      case "Cancelled":
        return Colors.red.shade900;
      case "In Progress":
        return Colors.amber.shade600;
      case "Not started":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget buildFilter(
      String label,
      RxList<String> items,
      RxString selectedValue,
      ) {
    final isDark = Get.isDarkMode;
    return Obx(
          () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: isDark ? dmSurfaceColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? dmBorderColor : Colors.grey.shade300,
              width: 0.5,
            )
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue.value,
            icon: Icon(
              Icons.arrow_drop_down,
              color: isDark ? dmIconColor : Colors.black54,
            ),
            style: GoogleFonts.cairo(
              color: isDark ? dmTextColorPrimary : Colors.black87,
            ),
            dropdownColor: isDark ? dmSurfaceColor : Colors.white,
            onChanged: (val) {
              if (val != null) selectedValue.value = val;
            },
            items: items
                .map(
                  (e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: GoogleFonts.cairo(color: isDark ? dmTextColorPrimary : Colors.black87)),
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget buildMonthFilter() {
    final isDark = Get.isDarkMode;
    return Obx(
          () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: isDark ? dmSurfaceColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? dmBorderColor : Colors.grey.shade300,
              width: 0.5,
            )
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.months[controller.selectedMonth.value],
            icon: Icon(
              Icons.arrow_drop_down,
              color: isDark ? dmIconColor : Colors.black54,
            ),
            style: GoogleFonts.cairo(
              color: isDark ? dmTextColorPrimary : Colors.black87,
            ),
            dropdownColor: isDark ? dmSurfaceColor : Colors.white,
            onChanged: (val) {
              if (val != null) {
                controller.selectedMonth.value = controller.months.indexOf(val);
              }
            },
            items: controller.months
                .map(
                  (m) => DropdownMenuItem(
                value: m,
                child: Text(m, style: GoogleFonts.cairo(color: isDark ? dmTextColorPrimary : Colors.black87)),
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }

  void showStatusPopup(BuildContext context, int subId) {
    final RxString sel = ''.obs;
    final isDark = Get.isDarkMode;
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? dmCardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Change Status",
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? dmTextColorPrimary : Colors.black,
          ),
        ),
        content: Obx(() {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: sel.value.isEmpty ? null : sel.value,
                hint: Text(
                  "Select new status",
                  style: GoogleFonts.cairo(
                    color: isDark ? dmTextColorSecondary : Colors.black87,
                  ),
                ),
                dropdownColor: isDark ? dmSurfaceColor : Colors.white,
                style: GoogleFonts.cairo(
                  color: isDark ? dmTextColorPrimary : Colors.black,
                ),
                icon: Icon(Icons.arrow_drop_down, color: isDark ? dmIconColor : Colors.black54),
                items: controller.statusList
                    .where((s) => s != "All Statuses")
                    .map(
                      (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: GoogleFonts.cairo()),
                  ),
                )
                    .toList(),
                onChanged: (v) async {
                  if (v != null) {
                    sel.value = v;
                    await controller.updateSubTaskField(
                      subTaskId: subId,
                      field: 'status',
                      newValue: v,
                    );
                    Get.back();
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  void showDeadlinePopup(BuildContext context, int subId, String current) {
    final isDark = Get.isDarkMode;
    final ctrl = TextEditingController()
      ..text = DateFormat('yyyy/MM/dd').format(DateTime.parse(current));
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? dmCardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Edit Deadline",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? dmTextColorPrimary : Colors.black,
          ),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.datetime,
          style: GoogleFonts.cairo(color: isDark ? dmTextColorPrimary : Colors.black),
          decoration: InputDecoration(
            labelText: "yyyy/MM/dd",
            labelStyle: GoogleFonts.cairo(color: isDark ? dmTextColorSecondary : Colors.grey.shade700),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: isDark ? dmIconColor : Colors.black54,
              ),
              onPressed: () async {
                final p = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(current),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: isDark ? ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: dmSurfaceColor,
                          onPrimary: dmTextColorPrimary,
                          onSurface: dmTextColorPrimary,
                        ),
                        dialogBackgroundColor: dmCardColor,
                      ) : ThemeData.light(),
                      child: child!,
                    );
                  },
                );
                if (p != null) {
                  ctrl.text = DateFormat('yyyy/MM/dd').format(p);
                }
              },
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? dmBorderColor : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? dmIconColor : Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: isDark ? dmSurfaceColor.withOpacity(0.5) : Colors.grey.shade100,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final pd = DateFormat('yyyy/MM/dd').parseStrict(ctrl.text);
                await controller.updateSubTaskField(
                  subTaskId: subId,
                  field: 'deadlineDate',
                  newValue: DateFormat('yyyy-MM-dd').format(pd),
                );
                Get.back();
              } catch (_) {
                Get.snackbar(
                  "Error",
                  "Invalid date format",
                  backgroundColor: Colors.red.shade700,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? dmSurfaceColor : Theme.of(context).primaryColor,
              foregroundColor: dmTextColorPrimary,
            ),
            child: Text(
              "Save",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void showNotePopup(BuildContext context, int subId, String current) {
    final isDark = Get.isDarkMode;
    final ctrl = TextEditingController()..text = current;
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? dmCardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Edit Note",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? dmTextColorPrimary : Colors.black,
          ),
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: GoogleFonts.cairo(color: isDark ? dmTextColorPrimary : Colors.black),
          decoration: InputDecoration(
            hintText: "Enter note",
            hintStyle: GoogleFonts.cairo(color: isDark ? dmTextColorSecondary : Colors.grey.shade600),
            filled: true,
            fillColor: isDark ? dmSurfaceColor.withOpacity(0.5) : Colors.grey[100],
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? dmBorderColor : Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? dmIconColor : Theme.of(context).primaryColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.updateSubTaskField(
                subTaskId: subId,
                field: 'note',
                newValue: ctrl.text.trim(),
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? dmSurfaceColor : Theme.of(context).primaryColor,
              foregroundColor: dmTextColorPrimary,
            ),
            child: Text(
              "Save",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void showLinkDialog(BuildContext context, int subId) {
    controller.showLinkDialog(context, subId);
  }

  void showEditorDialog(BuildContext context, int subId) {
    controller.showEditorDialog(context, subId);
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? dmGradientColors[0] : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Sidebar(isDarkMode: isDark),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                        colors: dmGradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 1.0],
                      )
                          : null,
                      color: isDark ? null : Theme.of(context).canvasColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 80.0, 24.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sub-Tasks Overview",
                            style: GoogleFonts.cairo(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDark ? dmTextColorPrimary : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                buildFilter(
                                  "SubTask Name",
                                  controller.subTaskNameList,
                                  controller.selectedSubTaskName,
                                ),
                                const SizedBox(width: 16),
                                buildFilter(
                                  "Editor",
                                  controller.editorList,
                                  controller.selectedEditor,
                                ),
                                const SizedBox(width: 16),
                                buildFilter(
                                  "Status",
                                  controller.statusList,
                                  controller.selectedStatus,
                                ),
                                const SizedBox(width: 16),
                                buildMonthFilter(),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: Icon(Icons.arrow_back_ios, color: isDark ? dmIconColor : Colors.black54),
                                  onPressed: () =>
                                      tableScrollController.animateTo(
                                        tableScrollController.offset - 200,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios, color: isDark ? dmIconColor : Colors.black54),
                                  onPressed: () =>
                                      tableScrollController.animateTo(
                                        tableScrollController.offset + 200,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.refresh, color: isDark ? dmIconColor : Colors.black54),
                                  tooltip: "Refresh",
                                  onPressed: () async {
                                    await controller.fetchSubTasks();
                                    Get.snackbar(
                                      "Refreshed",
                                      "Sub-task list updated",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: isDark ? dmSurfaceColor : Colors.grey.shade300,
                                      colorText: isDark ? dmTextColorPrimary : Colors.black87,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(() {
                            return Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    controller.selectingMode.value = !controller.selectingMode.value;
                                    if (!controller.selectingMode.value) {
                                      controller.selectedSubTaskIds.clear();
                                    }
                                  },
                                  icon: Icon(controller.selectingMode.value ? Icons.cancel_outlined : Icons.select_all, size: 20),
                                  label: Text(
                                    controller.selectingMode.value ? "Cancel Selection" : "Select Tasks",
                                    style: GoogleFonts.cairo(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: controller.selectingMode.value
                                        ? (isDark ? Colors.grey.shade600 : Colors.grey.shade500)
                                        : (isDark ? dmSurfaceColor : Colors.blueAccent),
                                    foregroundColor: dmTextColorPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (controller.selectingMode.value)
                                  ElevatedButton.icon(
                                    onPressed: controller.selectedSubTaskIds.isEmpty
                                        ? null
                                        : () {
                                      Get.defaultDialog(
                                        title: "Confirm Deletion",
                                        middleText: "Are you sure you want to delete ${controller.selectedSubTaskIds.length} selected sub-task(s)? This action cannot be undone.",
                                        titleStyle: GoogleFonts.cairo(color: isDark ? dmTextColorPrimary : Colors.black, fontWeight: FontWeight.bold),
                                        middleTextStyle: GoogleFonts.cairo(color: isDark ? dmTextColorSecondary : Colors.black87),
                                        backgroundColor: isDark ? dmCardColor : Colors.white,
                                        textConfirm: "Delete",
                                        textCancel: "Cancel",
                                        confirmTextColor: Colors.white,
                                        cancelTextColor: isDark ? dmTextColorSecondary : Colors.black54,
                                        buttonColor: Colors.red.shade700,
                                        onConfirm: () async {
                                          Get.back();
                                          // Iterate over a copy of the list if modifying it during iteration
                                          List<int> idsToDelete = List.from(controller.selectedSubTaskIds);
                                          for (var id in idsToDelete) {
                                            await controller.deleteSubTask(id);
                                          }
                                          controller.selectedSubTaskIds.clear();
                                          Get.snackbar(
                                            "Deleted",
                                            "Selected sub-tasks deleted successfully.",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.green.shade600,
                                            colorText: Colors.white,
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                                    label: Text("Delete Selected (${controller.selectedSubTaskIds.length})", style: GoogleFonts.cairo(fontSize: 14)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade700,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: isDark ? Colors.red.shade900.withOpacity(0.5) : Colors.red.shade200,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                              ],
                            );
                          }),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                  cardColor: isDark ? dmCardColor : Colors.white,
                                  textTheme: Theme.of(context).textTheme.apply(
                                    fontFamily: GoogleFonts.cairo().fontFamily,
                                    bodyColor: isDark ? dmTextColorPrimary : Colors.black87,
                                    displayColor: isDark ? dmTextColorPrimary : Colors.black87,
                                  ),
                                  dataTableTheme: DataTableThemeData(
                                    decoration: BoxDecoration(
                                        color: isDark ? dmCardColor.withOpacity(0.7) : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isDark ? dmBorderColor : Colors.grey.shade300, width: 0.5)
                                    ),
                                    dataRowMinHeight: 60,
                                    dataRowMaxHeight: 90,
                                    headingRowHeight: 56,
                                    headingRowColor: MaterialStateProperty.all(isDark ? dmSurfaceColor : Colors.grey[200]),
                                    headingTextStyle: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark ? dmTextColorPrimary : Colors.black,
                                    ),
                                    dataTextStyle: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: isDark ? dmTextColorSecondary : Colors.black87,
                                    ),
                                    dividerThickness: 0.5,
                                    horizontalMargin: 12,
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    thumbVisibility: MaterialStateProperty.all(true),
                                    thickness: MaterialStateProperty.all(8.0),
                                    radius: const Radius.circular(4),
                                    thumbColor: MaterialStateProperty.all(isDark ? dmScrollbarThumbColor.withOpacity(0.6) : Colors.grey.shade500),
                                    trackColor: MaterialStateProperty.all(isDark ? dmScrollbarTrackColor.withOpacity(0.3) : Colors.grey.shade300),
                                    trackBorderColor: MaterialStateProperty.all(isDark ? dmBorderColor : Colors.grey.shade400),
                                  )
                              ),
                              child: Obx(() {
                                final subs = controller.filteredSubTasks;
                                if (subs.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.list_alt_outlined, size: 60, color: isDark ? dmTextColorSecondary.withOpacity(0.5) : Colors.grey.shade400),
                                        const SizedBox(height: 16),
                                        Text(
                                            "No sub-tasks available.", // Simplified message
                                            style: GoogleFonts.cairo(color: isDark ? dmTextColorSecondary : Colors.grey.shade600, fontSize: 16)
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Scrollbar(
                                  controller: verticalScrollController,
                                  child: SingleChildScrollView(
                                    controller: verticalScrollController,
                                    scrollDirection: Axis.vertical,
                                    child: Scrollbar(
                                      controller: tableScrollController,
                                      child: SingleChildScrollView(
                                        controller: tableScrollController,
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columns: [
                                            if (controller.selectingMode.value)
                                              const DataColumn(label: Text("Select")), // Original simple "Select" label
                                            const DataColumn(label: Text("ID")),
                                            const DataColumn(label: Text("Name")),
                                            const DataColumn(label: Text("Start Date")),
                                            const DataColumn(label: Text("Deadline")),
                                            const DataColumn(label: Text("Status")),
                                            const DataColumn(label: Text("Editor")),
                                            const DataColumn(label: Text("Note")),
                                            const DataColumn(label: Text("Links")),
                                          ],
                                          rows: subs.map((sub) {
                                            return DataRow(
                                              color: MaterialStateProperty.resolveWith<Color?>((states) {
                                                if (states.contains(MaterialState.selected)) {
                                                  return (isDark ? dmSurfaceColor : Theme.of(context).primaryColor).withOpacity(0.2);
                                                }
                                                return null;
                                              }),
                                              selected: controller.selectedSubTaskIds.contains(sub.id),
                                              onSelectChanged: controller.selectingMode.value
                                                  ? (sel) { // Using original logic from your first provided code
                                                if (sel == true) {
                                                  if (!controller.selectedSubTaskIds.contains(sub.id)) {
                                                    controller.selectedSubTaskIds.add(sub.id);
                                                  }
                                                } else {
                                                  controller.selectedSubTaskIds.remove(sub.id);
                                                }
                                              }
                                                  : null,
                                              cells: [
                                                if (controller.selectingMode.value)
                                                  DataCell(
                                                    Checkbox(
                                                      value: controller.selectedSubTaskIds.contains(sub.id),
                                                      onChanged: (sel) { // Using original logic from your first provided code
                                                        if (sel == true) {
                                                          if (!controller.selectedSubTaskIds.contains(sub.id)) {
                                                            controller.selectedSubTaskIds.add(sub.id);
                                                          }
                                                        } else {
                                                          controller.selectedSubTaskIds.remove(sub.id);
                                                        }
                                                      },
                                                      activeColor: isDark? dmSurfaceColor : Theme.of(context).primaryColor,
                                                      checkColor: dmTextColorPrimary,
                                                    ),
                                                  ),
                                                DataCell(Text(sub.id.toString())),
                                                DataCell(SizedBox(width: 150, child: Text(sub.name, overflow: TextOverflow.ellipsis))),
                                                DataCell(Text(DateFormat('dd MMM yy').format(DateTime.parse(sub.startDate)))),
                                                DataCell(
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(DateFormat('dd MMM yy').format(DateTime.parse(sub.deadlineDate))),
                                                      if (controller.userType.value == "admin")
                                                        IconButton(
                                                          icon: const Icon(Icons.calendar_today_outlined),
                                                          iconSize: 18,
                                                          color: isDark ? dmIconColor : Colors.black54,
                                                          tooltip: "Edit Deadline",
                                                          onPressed: () => showDeadlinePopup(context, sub.id, sub.deadlineDate),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                DataCell(
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        decoration: BoxDecoration(
                                                          color: getStatusColor(sub.status).withOpacity(isDark ? 0.25 : 0.15),
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        child: Text(
                                                          sub.status,
                                                          style: GoogleFonts.cairo(color: getStatusColor(sub.status), fontWeight: FontWeight.bold, fontSize: 12),
                                                        ),
                                                      ),
                                                      if (controller.userType.value == "admin")
                                                        IconButton(
                                                          icon: const Icon(Icons.edit_outlined),
                                                          iconSize: 18,
                                                          color: isDark ? dmIconColor : Colors.black54,
                                                          tooltip: "Change Status",
                                                          onPressed: () => showStatusPopup(context, sub.id),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                DataCell(
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Expanded(child: Text(sub.editor, overflow: TextOverflow.ellipsis)),
                                                      if (controller.userType.value == "admin")
                                                        IconButton(
                                                          icon: const Icon(Icons.person_outline),
                                                          iconSize: 18,
                                                          color: isDark ? dmIconColor : Colors.black54,
                                                          tooltip: "Change Editor",
                                                          onPressed: () => showEditorDialog(context, sub.id),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                DataCell(
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Expanded(child: Text(sub.note, overflow: TextOverflow.ellipsis, maxLines: 2)),
                                                      if (controller.userType.value == "admin")
                                                        IconButton(
                                                          icon: const Icon(Icons.note_alt_outlined),
                                                          iconSize: 18,
                                                          color: isDark ? dmIconColor : Colors.black54,
                                                          tooltip: "Edit Note",
                                                          onPressed: () => showNotePopup(context, sub.id, sub.note),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 200,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        if (controller.userType.value == "admin" && sub.links.trim().isNotEmpty)
                                                          Align(
                                                            alignment: Alignment.centerRight,
                                                            child: IconButton(
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints(),
                                                              icon: const Icon(Icons.link_outlined),
                                                              iconSize: 18,
                                                              color: isDark ? dmIconColor : Colors.black54,
                                                              tooltip: "Edit Links",
                                                              onPressed: () => showLinkDialog(context, sub.id),
                                                            ),
                                                          ),
                                                        ...sub.links.split(' - ').where((link) => link.trim().isNotEmpty).take(2).map((link) {
                                                          final trimmed = link.trim();
                                                          return Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    trimmed,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                    style: GoogleFonts.cairo(fontSize: 11, color: isDark ? dmTextColorSecondary : Colors.blue.shade700),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 4),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Clipboard.setData(ClipboardData(text: trimmed));
                                                                    Get.snackbar(
                                                                      "Copied", "Link copied: $trimmed",
                                                                      snackPosition: SnackPosition.BOTTOM,
                                                                      backgroundColor: isDark ? dmSurfaceColor : Colors.grey.shade300,
                                                                      colorText: isDark ? dmTextColorPrimary : Colors.black87,
                                                                    );
                                                                  },
                                                                  child: Icon(Icons.copy_all_outlined, size: 15, color: isDark ? dmIconColor.withOpacity(0.7) : Colors.grey.shade600),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
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
                ),
              ],
            ),
            TopBarWidget(),
          ],
        ),
      ),
    );
  }
}