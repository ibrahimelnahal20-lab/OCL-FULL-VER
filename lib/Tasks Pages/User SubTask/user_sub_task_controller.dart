// File: lib/controllers/user_sub_task_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/API/API.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';

class UserSubTaskController extends GetxController {
  var isLoading = true.obs;
  var completeSubTasks = <Map<String, dynamic>>[].obs;
  var inProgressSubTasks = <Map<String, dynamic>>[].obs;
  var notStartedSubTasks = <Map<String, dynamic>>[].obs;
  var cancelledSubTasks = <Map<String, dynamic>>[].obs;
  RxString loggedInUsername = ''.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();
    loggedInUsername.value = box.read('loggedInUsername') ?? '';
    // أول جلب للبيانات
    fetchSubTasks();
    // مؤقت لإعادة جلب البيانات كل 30 ثانية
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchSubTasks(),
    );
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchSubTasks() async {
    try {
      isLoading(true);
      final response = await API.getData(EndPoints.subTasks);

      if (response.statusCode == 200 && response.data is List) {
        List<Map<String, dynamic>> subs = List<Map<String, dynamic>>.from(
          response.data,
        );

        DateTime now = DateTime.now();
        // وسم "Cancelled" للمهام المتأخرة
        for (var sub in subs) {
          if (sub['status'] != 'Complete') {
            DateTime deadline =
                DateTime.tryParse(sub['deadlineDate'] ?? '') ?? now;
            if (deadline.isBefore(now)) {
              sub['status'] = 'Cancelled';
            }
          }
        }

        // تصفية SubTasks حسب المُحرر (Editor)
        List<Map<String, dynamic>> filtered =
            subs.where((sub) {
              return sub['editor'].toString().contains(loggedInUsername.value);
            }).toList();

        // تقسيم حسب الحالة
        completeSubTasks.value =
            filtered.where((s) => s['status'] == 'Complete').toList();
        inProgressSubTasks.value =
            filtered.where((s) => s['status'] == 'In Progress').toList();
        notStartedSubTasks.value =
            filtered.where((s) => s['status'] == 'Not started').toList();
        cancelledSubTasks.value =
            filtered.where((s) => s['status'] == 'Cancelled').toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Error fetching subtasks: $e");
      }
    } finally {
      isLoading(false);
    }
  }

  /// تنسيق التاريخ لعرضه
  String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// حساب الوقت المتبقي بين الآن وموعد التسليم
  String calculateTimeRemaining(DateTime startDate, DateTime deadline) {
    Duration remaining = deadline.difference(DateTime.now());
    int days = remaining.inDays;
    int hours = remaining.inHours % 24;
    return "$days days, $hours hours";
  }

  /// تحديث حالة SubTask عبر PATCH
  Future<void> updateSubTaskStatus({
    required int subTaskId,
    required String newStatus,
    Function()? onSuccess,
  }) async {
    try {
      await API.patchData("SubTasks/$subTaskId", [
        {"op": "replace", "path": "/status", "value": newStatus},
      ]);
      await fetchSubTasks();
      if (onSuccess != null) onSuccess();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update subtask status",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// حوار إضافة روابط SubTask
  Future<void> showLinkDialog(int subTaskId) async {
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
                      (ctrl) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: TextField(
                          controller: ctrl,
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

          final allLinksJoined = links.join(" - ");
          try {
            await API.patchData("SubTasks/$subTaskId", [
              {"op": "add", "path": "/links", "value": allLinksJoined},
            ]);
            await updateSubTaskStatus(
              subTaskId: subTaskId,
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
        ),
      ),
    );
  }
}
