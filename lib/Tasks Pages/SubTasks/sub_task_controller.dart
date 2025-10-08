// File: lib/controllers/sub_task_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ocl2/API/api.dart';

class SubTaskController extends GetxController {
  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController editorController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Reactive variable for the selected editor (nullable)
  final RxnString selectedEditor = RxnString();

  // Lists for dropdowns
  final RxList<String> availableManagers = <String>[].obs;
  final RxList<String> availableTasks = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchManagers();
    fetchTasks();
  }

  Future<void> fetchManagers() async {
    try {
      final response = await API.getData(EndPoints.users);
      final allUsers =
          (response.data as List)
              .map<String>((u) => u['username'] as String)
              .toList();
      availableManagers.assignAll(allUsers);
      if (!availableManagers.contains('Assign later')) {
        availableManagers.add('Assign later');
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch managers: $e");
    }
  }

  Future<void> fetchTasks() async {
    try {
      final response = await API.getData(EndPoints.task);
      final names =
          (response.data as List)
              .map<String>((t) => t['taskName'] as String)
              .toList();
      availableTasks.assignAll(names);
    } catch (e) {
      debugPrint("❌ Failed to fetch tasks: $e");
    }
  }

  void pickDate(BuildContext context, TextEditingController controller, bool isDark) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  /// Create SubTask with status "Not started"
  Future<void> createSubTask() async {
    final subTaskData = {
      "id": 0,
      "name": nameController.text,
      "startDate": startDateController.text,
      "deadlineDate": deadlineController.text,
      "editor": editorController.text,
      "status": "Not started",
      "note": noteController.text,
    };

    try {
      await API.postData('SubTasks', subTaskData);

      // show success dialog in English
      Get.dialog(
        AlertDialog(
          backgroundColor: Get.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Success',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'SubTask created successfully.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Get.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      );

      _clearFields();
    } catch (e) {
      debugPrint("❌ Failed to create SubTask: $e");
      Get.snackbar(
        "Error",
        "Failed to create SubTask",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Clear all fields after creation
  void _clearFields() {
    nameController.clear();
    editorController.clear();
    selectedEditor.value = null; // reset dropdown
    statusController.clear();
    startDateController.clear();
    deadlineController.clear();
    noteController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    editorController.dispose();
    statusController.dispose();
    startDateController.dispose();
    deadlineController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
