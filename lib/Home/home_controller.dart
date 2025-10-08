// lib/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ocl2/API/API.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:ocl2/widgets/enhanced_snackbar.dart';

class TaskModel {
  final int taskID;
  final String taskName;
  final String taskStartDate;
  final String taskDeadLine;
  final String taskStatus;
  final String packages;
  final String extras;
  final String projectManager;
  final String noteManager;
  final String createdBy;
  final String links;

  TaskModel({
    required this.taskID,
    required this.taskName,
    required this.taskStartDate,
    required this.taskDeadLine,
    required this.taskStatus,
    required this.packages,
    required this.extras,
    required this.projectManager,
    required this.noteManager,
    required this.createdBy,
    required this.links,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskID: json['taskID'] ?? 0,
      taskName: json['taskName'] ?? '',
      taskStartDate: json['taskStartDate'] ?? '',
      taskDeadLine: json['taskDeadLine'] ?? '',
      taskStatus: json['taskStatus'] ?? '',
      packages: json['packages'] ?? '',
      extras: json['extras'] ?? '',
      projectManager: json['projectManager'] ?? '',
      noteManager: json['noteManager'] ?? '',
      createdBy: json['createdBy'] ?? '',
      links: json['links'] ?? '',
    );
  }
}

class HomeController extends GetxController {
  final GetStorage box = GetStorage();
  final TopBarController topBar = Get.find<TopBarController>();
  RxInt currentPage = 0.obs;
  RxBool isDarkMode = Get.isDarkMode.obs;

  RxList<TaskModel> allTasks = <TaskModel>[].obs;
  RxList<String> allEditors = <String>[].obs;
  RxList<int> selectedTaskIds = <int>[].obs;
  RxBool selectingMode = false.obs;

  RxList<String> projectList = <String>[].obs;
  RxList<String> employeeList = <String>[].obs;
  RxList<String> statusList =
      <String>[
        "All Statuses",
        "On Hold",
        "Complete",
        "In Progress",
        "Not started",
        "Cancelled",
      ].obs;

  RxString selectedProject = "All Projects".obs;
  RxString selectedEmployee = "All Editor".obs;
  RxString selectedStatus = "All Statuses".obs;

  /// الشهر المختار (0 = جميع الأشهر)
  RxInt selectedMonth = RxInt(DateTime.now().month);

  // لائحة الأشهر لاستخدامها في الـ Dropdown
  final List<String> months = const [
    'All Months',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  RxMap<String, TextEditingController> notes =
      <String, TextEditingController>{}.obs;

  RxString get loggedInUsername => topBar.loggedInUsername;
  RxString get userType => topBar.userType;
  RxString get userImageUrl => topBar.userImageUrl;

  RxList<String> packageNames = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    API.init();
    fetchTasks();
    fetchEditors();
    fetchPackages();

    ever(topBar.loggedInUsername, (_) {
      fetchTasks();
      fetchEditors();
      fetchPackages();
    });
    ever(topBar.userType, (_) {
      fetchTasks();
      fetchEditors();
      fetchPackages();
    });

    ever(selectedMonth, (_) => update());
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
  }

  List<TaskModel> get filteredTasks {
    return allTasks.where((task) {
      final dt = DateTime.tryParse(task.taskStartDate);

      final matchProject =
          selectedProject.value == "All Projects" ||
          task.taskName == selectedProject.value;

      final matchEmployee =
          selectedEmployee.value == "All Editor" ||
          task.projectManager.split(" - ").contains(selectedEmployee.value);

      final matchStatus =
          selectedStatus.value == "All Statuses" ||
          task.taskStatus == selectedStatus.value;

      final matchMonth =
          selectedMonth.value == 0 ||
          (dt != null && dt.month == selectedMonth.value);

      return matchProject && matchEmployee && matchStatus && matchMonth;
    }).toList();
  }

  Future<void> fetchTasks() async {
    try {
      final response = await API.getData("Tasks");
      if (response.statusCode == 200 && response.data is List) {
        var tasks =
            (response.data as List).map((e) => TaskModel.fromJson(e)).toList();

        if (userType.value == "user") {
          tasks =
              tasks
                  .where(
                    (t) => t.projectManager
                        .split(" - ")
                        .contains(loggedInUsername.value),
                  )
                  .toList();
        }

        allTasks.value = tasks;
        await _updateExpiredStatuses();

        final projects = allTasks.map((e) => e.taskName).toSet().toList();
        projectList.value = ["All Projects", ...projects];
        update();
      }
    } catch (e) {
      debugPrint("❌ Error loading tasks: $e");
    }
  }

  Future<void> _updateExpiredStatuses() async {
    final now = DateTime.now();
    bool updated = false;

    for (var task in allTasks) {
      final deadline = DateTime.parse(task.taskDeadLine);
      if (deadline.isBefore(now) &&
          task.taskStatus != "Cancelled" &&
          task.taskStatus != "Complete") {
        await API.patchData("Tasks/${task.taskID}", [
          {"op": "replace", "path": "/taskStatus", "value": "Cancelled"},
        ]);
        updated = true;
      }
    }

    if (updated) {
      final resp = await API.getData("Tasks");
      if (resp.statusCode == 200 && resp.data is List) {
        allTasks.value =
            (resp.data as List).map((e) => TaskModel.fromJson(e)).toList();
      }
    }
  }

  Future<void> fetchEditors() async {
    try {
      final response = await API.getData("Users");
      if (response.statusCode == 200 && response.data is List) {
        final editors =
            (response.data as List)
                .map((e) => e['username'].toString())
                .where((e) => e.isNotEmpty)
                .toSet()
                .toList();

        employeeList.value =
            userType.value == "user"
                ? ["All Editor", loggedInUsername.value]
                : ["All Editor", ...editors];

        update();
      }
    } catch (e) {
      debugPrint("❌ Error loading editors: $e");
    }
  }

  Future<void> updateTaskStatus({
    required int taskId,
    required String newStatus,
    Function()? onSuccess,
  }) async {
    try {
      await API.patchData("Tasks/$taskId", [
        {"op": "replace", "path": "/taskStatus", "value": newStatus},
      ]);
      await fetchTasks();
      update();
      onSuccess?.call();
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text(
            "Error",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            "Failed to update task status",
            style: GoogleFonts.poppins(
              color: Get.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          backgroundColor:
              Get.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
      update();
    }
  }

  Future<void> updateTaskField({
    required int taskId,
    required String field,
    required String newValue,
    Function()? onSuccess,
  }) async {
    try {
      await API.patchData("Tasks/$taskId", [
        {"op": "replace", "path": "/$field", "value": newValue},
      ]);
      await fetchTasks();
      update();
      onSuccess?.call();
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text(
            "Error",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            "Failed to update $field",
            style: GoogleFonts.poppins(
              color: Get.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          backgroundColor:
              Get.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
      debugPrint("❌ Error updating $field: $e");
      update();
    }
  }

  Future<void> updateTaskDeadline({
    required int taskId,
    required DateTime newDeadline,
    Function()? onSuccess,
  }) async {
    try {
      final formatted = newDeadline.toIso8601String().split("T").first;
      await API.patchData("Tasks/$taskId", [
        {"op": "replace", "path": "/taskDeadLine", "value": formatted},
      ]);
      await fetchTasks();
      update();
      onSuccess?.call();
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text(
            "Error",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            "Failed to update deadline",
            style: GoogleFonts.poppins(
              color: Get.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          backgroundColor:
              Get.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
      update();
    }
  }

  Future<void> fetchPackages() async {
    try {
      final response = await API.getData("Packages");
      if (response.statusCode == 200 && response.data is List) {
        final data = List<Map<String, dynamic>>.from(response.data);
        packageNames.assignAll(
          data.map((pkg) => pkg["packageName"].toString()),
        );
      }
    } catch (e) {
      debugPrint("❌ Error loading packages: $e");
    }
  }

  Future<void> showDeadlineDialog(
    BuildContext context,
    int taskId,
    String currentDeadline,
  ) async {
    final isDark = Get.isDarkMode;
    final controllerDate =
        TextEditingController()
          ..text = DateFormat(
            'yyyy/MM/dd',
          ).format(DateTime.parse(currentDeadline));

    await Get.defaultDialog(
      title: "Edit Deadline Date",
      titleStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
        fontSize: 20,
      ),
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      radius: 16,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controllerDate,
            keyboardType: TextInputType.datetime,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: "yyyy/MM/dd",
              labelStyle: GoogleFonts.poppins(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              filled: true,
              fillColor: isDark ? Colors.black38 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.parse(currentDeadline),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Get.theme.copyWith(
                          colorScheme:
                              isDark
                                  ? const ColorScheme.dark(
                                    primary: Color(0xFF5577FF),
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF2C2C2C),
                                    onSurface: Colors.white,
                                  )
                                  : const ColorScheme.light(
                                    primary: Color(0xFF5577FF),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                          textTheme: GoogleFonts.poppinsTextTheme(
                            isDark
                                ? ThemeData.dark().textTheme
                                : ThemeData.light().textTheme,
                          ),
                          dialogTheme: DialogThemeData(
                            // Corrected to DialogThemeData
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    controllerDate.text = DateFormat(
                      'yyyy/MM/dd',
                    ).format(picked);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          try {
            final parsed = DateFormat(
              'yyyy/MM/dd',
            ).parseStrict(controllerDate.text.trim());
            final fmt = DateFormat('yyyy-MM-dd').format(parsed);
            await updateTaskField(
              taskId: taskId,
              field: 'taskDeadLine',
              newValue: fmt,
            );
            Get.back();
          } catch (_) {
            EnhancedSnackBar.showError(
              title: "Error",
              message: "Invalid date format",
            );
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
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          "Cancel",
          style: GoogleFonts.poppins(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> updateTaskExtras({
    required int taskId,
    required String newExtras,
    Function()? onSuccess,
  }) async {
    try {
      await API.patchData("Tasks/$taskId", [
        {"op": "replace", "path": "/extras", "value": newExtras},
      ]);
      await fetchTasks();
      update();
      onSuccess?.call();
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text(
            "Error",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            "Failed to update extras",
            style: GoogleFonts.poppins(
              color: Get.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          backgroundColor:
              Get.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
      update();
    }
  }

  Future<void> updateTaskPackages({
    required int taskId,
    required String newPackages,
    Function()? onSuccess,
  }) async {
    try {
      await API.patchData("Tasks/$taskId", [
        {"op": "replace", "path": "/packages", "value": newPackages},
      ]);
      await fetchTasks();
      update();
      onSuccess?.call();
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text(
            "Error",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            "Failed to update packages",
            style: GoogleFonts.poppins(
              color: Get.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          backgroundColor:
              Get.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
      update();
    }
  }

  Future<void> showLinkDialog(int taskId) async {
    final isDark = Get.isDarkMode;
    List<TextEditingController> linkControllers = [TextEditingController()];
    RxString errorText = ''.obs;

    await Get.defaultDialog(
      title: "Add Link(s)",
      titleStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
        fontSize: 20,
      ),
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      radius: 16,
      content: StatefulBuilder(
        builder:
            (context, setState) => Obx(() {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...linkControllers.map(
                      (c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextField(
                          controller: c,
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: "https://galleries.vidflow.co/...",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey.shade500,
                            ),
                            filled: true,
                            fillColor:
                                isDark ? Colors.black38 : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    isDark
                                        ? Colors.white24
                                        : Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Get.theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(
                          () => linkControllers.add(TextEditingController()),
                        );
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Get.theme.primaryColor,
                        size: 20,
                      ),
                      label: Text(
                        "Add Another Link",
                        style: GoogleFonts.poppins(
                          color: Get.theme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (errorText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorText.value,
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
      ),
      confirm: ElevatedButton.icon(
        onPressed: () async {
          final links =
              linkControllers
                  .map((c) => c.text.trim())
                  .where((l) => l.isNotEmpty)
                  .toList();
          if (links.isEmpty) {
            errorText.value = "Please add at least one link.";
            return;
          }
          if (!links.first.startsWith("https://galleries.vidflow.co/")) {
            errorText.value =
                "The first link must start with https://galleries.vidflow.co/";
            return;
          }
          final joined = links.join(" - ");
          try {
            await API.patchData("Tasks/$taskId", [
              {"op": "add", "path": "/links", "value": joined},
            ]);
            await updateTaskStatus(
              taskId: taskId,
              newStatus: "Complete",
              onSuccess: () => Get.back(),
            );
            EnhancedSnackBar.showSuccess(
              title: "Success",
              message: "Link(s) added and status updated successfully",
            );
          } catch (_) {
            errorText.value = "❌ Failed to send link(s). Try again.";
            EnhancedSnackBar.showError(
              title: "Error",
              message: "Failed to send link(s). Try again.",
            );
          }
        },
        icon: const Icon(Icons.send_rounded, size: 20),
        label: Text(
          "Submit",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          "Cancel",
          style: GoogleFonts.poppins(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final confirmed = await Get.defaultDialog<bool>(
        title: "Confirm Deletion",
        titleStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
        content: Text(
          "Are you sure you want to delete this task?",
          style: GoogleFonts.poppins(
            color: Get.isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        backgroundColor:
            Get.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        radius: 16,
        textCancel: "Cancel",
        textConfirm: "Delete",
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
        cancelTextColor: Get.isDarkMode ? Colors.white70 : Colors.black87,
      );
      if (confirmed == true) {
        final resp = await API.deleteData("Tasks/$taskId");
        if (resp.statusCode == 200 || resp.statusCode == 204) {
          await fetchTasks();
          EnhancedSnackBar.showSuccess(
            title: "Deleted",
            message: "Task deleted successfully",
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error deleting task: $e");
      EnhancedSnackBar.showError(
        title: "Error",
        message: "Failed to delete task",
      );
    }
  }

  Future<void> deleteSelectedTasks() async {
    for (final id in selectedTaskIds) {
      await deleteTask(id);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    selectedTaskIds.clear();
  }

  void toggleTaskSelection(int taskId) {
    if (selectedTaskIds.contains(taskId)) {
      selectedTaskIds.remove(taskId);
    } else {
      selectedTaskIds.add(taskId);
    }
  }

  void toggleSelectAll(List<TaskModel> tasks) {
    final allIds = tasks.map((e) => e.taskID).toList();
    if (selectedTaskIds.length == allIds.length) {
      selectedTaskIds.clear();
    } else {
      selectedTaskIds.assignAll(allIds);
    }
  }

  void changePage(int pageIndex) {
    currentPage.value = pageIndex;
    update();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    update();
  }

  void saveLastPage(String pageName) {
    box.write('lastPage', pageName);
    update();
  }

  // إضافة دالة getStatusColor
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

  // إضافة دالة showManagerPopup
  void showManagerPopup(
    BuildContext context,
    List<String> allManagers,
    int taskId,
  ) {
    final RxList<String> selectedManagers = <String>[].obs;
    final RxMap<String, TextEditingController> notes =
        <String, TextEditingController>{}.obs;

    selectedManagers.clear();
    notes.clear();

    Get.dialog(
      AlertDialog(
        backgroundColor:
            Get.isDarkMode ? const Color(0xFF161B22) : Colors.white,
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
                              ? const Color(0xFF161B22).withOpacity(0.5)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            Get.isDarkMode
                                ? const Color(0xFF30363D)
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
                            Get.isDarkMode
                                ? const Color(0xFF21262C)
                                : Colors.white,
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
                                    ? const Color(0xFF161B22).withOpacity(0.5)
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
                  await fetchTasks();
                  Get.back();
                  EnhancedSnackBar.showSuccess(
                    title: "Success",
                    message: "Managers updated successfully",
                  );
                } catch (e) {
                  EnhancedSnackBar.showError(
                    title: "Error",
                    message: "Failed to update managers",
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

  // إضافة دالة showStatusPopup
  void showStatusPopup(BuildContext context, int taskId) {
    final RxString selectedStatus = ''.obs;
    final isDark = Get.isDarkMode;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
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
                  isDark
                      ? const Color(0xFF161B22).withOpacity(0.5)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
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
                dropdownColor: isDark ? const Color(0xFF21262C) : Colors.white,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
                items:
                    statusList
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
                    await updateTaskField(
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
                await updateTaskField(
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
}
