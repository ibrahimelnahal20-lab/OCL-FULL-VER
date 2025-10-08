import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:ocl2/API/API.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class UserTaskController extends GetxController {
  var isLoading = true.obs;
  var completeTasks = <Map<String, dynamic>>[].obs;
  var inProgressTasks = <Map<String, dynamic>>[].obs;
  var notStartedTasks = <Map<String, dynamic>>[].obs;
  var cancelledTasks = <Map<String, dynamic>>[].obs;
  RxString loggedInUsername = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();
    loggedInUsername.value = box.read('loggedInUsername') ?? '';
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading(true);
      final response = await API.getData(EndPoints.task);

      if (response.statusCode == 200 && response.data is List) {
        List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(
          response.data,
        );

        if (kDebugMode) {
          debugPrint("🚀 All tasks fetched from API:");
          for (var task in tasks) {
            debugPrint(task.toString());
          }
        }

        DateTime now = DateTime.now();

        for (var task in tasks) {
          if (task['taskStatus'] != 'Complete') {
            DateTime deadline =
                DateTime.tryParse(task['taskDeadLine'] ?? '') ?? now;
            if (deadline.isBefore(now)) {
              task['taskStatus'] = 'Cancelled';
            }
          }
        }

        List<Map<String, dynamic>> filteredTasks =
            tasks
                .where(
                  (task) => task["projectManager"].toString().contains(
                    loggedInUsername.value,
                  ),
                )
                .toList();

        if (kDebugMode) {
          debugPrint("🎯 Filtered tasks for user (${loggedInUsername.value}):");
          for (var task in filteredTasks) {
            debugPrint(task.toString());
          }
        }

        completeTasks.value =
            filteredTasks
                .where((task) => task["taskStatus"] == "Complete")
                .toList();
        inProgressTasks.value =
            filteredTasks
                .where((task) => task["taskStatus"] == "In Progress")
                .toList();
        notStartedTasks.value =
            filteredTasks
                .where((task) => task["taskStatus"] == "Not started")
                .toList();
        cancelledTasks.value =
            filteredTasks
                .where((task) => task["taskStatus"] == "Cancelled")
                .toList();

        if (kDebugMode) {
          debugPrint("✅ Complete Tasks: ${completeTasks.length}");
          debugPrint("🚧 In Progress Tasks: ${inProgressTasks.length}");
          debugPrint("🚦 Not Started Tasks: ${notStartedTasks.length}");
          debugPrint("❌ Cancelled Tasks: ${cancelledTasks.length}");
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint("❌ Error: $e");
    } finally {
      isLoading(false);
    }
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  String calculateTimeRemaining(DateTime startDate, DateTime deadline) {
    Duration remaining = deadline.difference(DateTime.now());
    int days = remaining.inDays;
    int hours = remaining.inHours % 24;
    return "$days days, $hours hours";
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
      fetchTasks();
      if (onSuccess != null) onSuccess();
    } catch (e) {
      Get.snackbar("Error", "Failed to update task status");
    }
  }

  Future<void> showLinkDialog(int taskId) async {
    final isDark = Get.isDarkMode;
    List<TextEditingController> linkControllers = [TextEditingController()];
    RxString errorText = ''.obs;

    await Get.defaultDialog(
      title: "Add Link(s)",
      titleStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      radius: 16,
      content: StatefulBuilder(
        builder:
            (context, setState) => Obx(
              () => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...linkControllers.map(
                      (controller) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: TextField(
                          controller: controller,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: "https://galleries.vidflow.co/...",
                            hintStyle: GoogleFonts.poppins(
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            labelText: "Link",
                            labelStyle: GoogleFonts.poppins(),
                            filled: true,
                            fillColor:
                                isDark ? Colors.black12 : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Get.theme.colorScheme.primary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          linkControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: Text(
                        "Add Another Link",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (errorText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          errorText.value,
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ),
      confirm: ElevatedButton.icon(
        onPressed: () async {
          List<String> links =
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

          String allLinksJoined = links.join(" - ");

          try {
            await API.patchData("Tasks/$taskId", [
              {"op": "add", "path": "/links", "value": allLinksJoined},
            ]);

            await updateTaskStatus(
              taskId: taskId,
              newStatus: "Complete",
              onSuccess: () => Get.back(),
            );
          } catch (_) {
            errorText.value = "❌ Failed to send link(s). Try again.";
          }
        },
        icon: const Icon(Icons.send),
        label: Text(
          "Submit",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
