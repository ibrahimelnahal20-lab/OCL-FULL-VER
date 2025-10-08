// lib/controllers/sub_task_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ocl2/API/API.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';

class SubTaskModel {
  final int id;
  final String name;
  final String startDate;
  final String deadlineDate;
  final String editor;
  final String status;
  final String note;
  final String links;

  SubTaskModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.deadlineDate,
    required this.editor,
    required this.status,
    required this.note,
    required this.links,
  });

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startDate: json['startDate'] ?? '',
      deadlineDate: json['deadlineDate'] ?? '',
      editor: json['editor'] ?? '',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      links: json['links']?.toString() ?? '',
    );
  }
}

class OverSubTaskController extends GetxController {
  final GetStorage box = GetStorage();
  final TopBarController topBar = Get.find<TopBarController>();
  RxInt currentPage = 0.obs;
  RxBool isDarkMode = Get.isDarkMode.obs;

  RxList<SubTaskModel> allSubTasks = <SubTaskModel>[].obs;
  RxList<String> subTaskNameList = <String>[].obs;
  RxList<String> editorList = <String>[].obs;
  RxList<String> statusList =
      <String>[
        "All Statuses",
        "On Hold",
        "Complete",
        "In Progress",
        "Not started",
        "Cancelled",
      ].obs;

  RxInt selectedMonth = RxInt(DateTime.now().month);
  final List<String> months = const [
    "All Months",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  RxString selectedSubTaskName = "All SubTasks".obs;
  RxString selectedEditor = "All Editors".obs;
  RxString selectedStatus = "All Statuses".obs;

  RxList<int> selectedSubTaskIds = <int>[].obs;
  RxBool selectingMode = false.obs;

  RxString get loggedInUsername => topBar.loggedInUsername;
  RxString get userType => topBar.userType;
  RxString get userImageUrl => topBar.userImageUrl;

  @override
  void onInit() {
    super.onInit();
    API.init();
    fetchEditors(); // جلب قائمة المحررين من Users
    fetchSubTasks(); // ثم جلب الصب-تاسكس

    ever(topBar.loggedInUsername, (_) {
      fetchEditors();
      fetchSubTasks();
    });
    ever(topBar.userType, (_) {
      fetchEditors();
      fetchSubTasks();
    });
    ever(selectedMonth, (_) => update());
  }

  /// فلترة الصب-تاسكس حسب الاسم، المحرر، الحالة والشهر
  List<SubTaskModel> get filteredSubTasks {
    return allSubTasks.where((sub) {
      final matchName =
          selectedSubTaskName.value == "All SubTasks" ||
          sub.name == selectedSubTaskName.value;
      final matchEditor =
          selectedEditor.value == "All Editors" ||
          sub.editor == selectedEditor.value;
      final matchStatus =
          selectedStatus.value == "All Statuses" ||
          sub.status == selectedStatus.value;
      final dt = DateTime.tryParse(sub.startDate);
      final matchMonth =
          selectedMonth.value == 0 ||
          (dt != null && dt.month == selectedMonth.value);
      return matchName && matchEditor && matchStatus && matchMonth;
    }).toList();
  }

  /// جلب الصب-تاسكس من الـ API + إلغاء المنتهية
  Future<void> fetchSubTasks() async {
    try {
      final response = await API.getData("SubTasks");
      if (response.statusCode == 200 && response.data is List) {
        var subs =
            (response.data as List)
                .map((e) => SubTaskModel.fromJson(e))
                .toList();

        if (userType.value == "user") {
          subs = subs.where((s) => s.editor == loggedInUsername.value).toList();
        }

        allSubTasks.value = subs;

        // إلغاء الصب-تاسكس المنتهية
        await _updateExpiredStatuses();

        // بناء قائمة أسماء الصب-تاسكس للفلاتر
        subTaskNameList.value = [
          "All SubTasks",
          ...allSubTasks.map((s) => s.name).toSet(),
        ];

        update();
      }
    } catch (e) {
      debugPrint("❌ Error loading subtasks: $e");
    }
  }

  /// تحديث حالات المنتهية تلقائياً
  Future<void> _updateExpiredStatuses() async {
    final now = DateTime.now();
    bool updated = false;

    for (var sub in allSubTasks) {
      final dl = DateTime.parse(sub.deadlineDate);
      if (dl.isBefore(now) &&
          sub.status != "Cancelled" &&
          sub.status != "Complete") {
        await API.patchData("SubTasks/${sub.id}", [
          {"op": "replace", "path": "/status", "value": "Cancelled"},
        ]);
        updated = true;
      }
    }

    if (updated) {
      final resp = await API.getData("SubTasks");
      if (resp.statusCode == 200 && resp.data is List) {
        allSubTasks.value =
            (resp.data as List).map((e) => SubTaskModel.fromJson(e)).toList();
      }
    }
  }

  /// جلب قائمة المحررين الكاملة من Users
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

        editorList.value =
            userType.value == "user"
                ? ["All Editors", loggedInUsername.value, ...editors]
                : ["All Editors", ...editors];

        update();
      }
    } catch (e) {
      debugPrint("❌ Error loading editors: $e");
    }
  }

  /// تحديث حقل في SubTask
  Future<void> updateSubTaskField({
    required int subTaskId,
    required String field,
    required String newValue,
    Function()? onSuccess,
  }) async {
    try {
      await API.patchData("SubTasks/$subTaskId", [
        {"op": "replace", "path": "/$field", "value": newValue},
      ]);
      await fetchSubTasks();
      update();
      onSuccess?.call();
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to update $field"),
        ),
      );
      update();
    }
  }

  /// تحديث تاريخ الانتهاء
  Future<void> updateSubTaskDeadline({
    required int subTaskId,
    required DateTime newDeadline,
    Function()? onSuccess,
  }) async {
    try {
      final formatted = DateFormat('yyyy-MM-dd').format(newDeadline);
      await API.patchData("SubTasks/$subTaskId", [
        {"op": "replace", "path": "/deadlineDate", "value": formatted},
      ]);
      await fetchSubTasks();
      update();
      onSuccess?.call();
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text("Error"),
          content: const Text("Failed to update deadline"),
        ),
      );
      update();
    }
  }

  /// حوار اختيار الصب-تاسك
  Future<void> showSubTaskNameDialog(BuildContext context) async {
    final isDark = Get.isDarkMode;
    await Get.defaultDialog(
      title: "Select Sub-task",
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      content: Obx(() {
        return DropdownButton<String>(
          isExpanded: true,
          value:
              selectedSubTaskName.value == "All SubTasks"
                  ? null
                  : selectedSubTaskName.value,
          hint: Text(
            "Choose sub-task",
            style: GoogleFonts.cairo(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          dropdownColor: isDark ? Colors.grey[850] : Colors.white,
          style: GoogleFonts.cairo(color: isDark ? Colors.white : Colors.black),
          items:
              subTaskNameList
                  .map(
                    (name) => DropdownMenuItem(
                      value: name,
                      child: Text(name, style: GoogleFonts.cairo()),
                    ),
                  )
                  .toList(),
          onChanged: (val) {
            if (val != null) {
              selectedSubTaskName.value = val;
              update();
            }
          },
        );
      }),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: Text(
          "OK",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// حوار تعديل المحرر والملاحظة
  Future<void> showEditorDialog(BuildContext context, int subTaskId) async {
    final isDark = Get.isDarkMode;
    RxString sel = ''.obs;
    final noteCtl = TextEditingController();

    await Get.defaultDialog(
      title: "Change Editor",
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      radius: 16,
      content: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              isExpanded: true,
              value: sel.value.isEmpty ? null : sel.value,
              hint: Text(
                "Choose Editor",
                style: GoogleFonts.cairo(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              dropdownColor: isDark ? Colors.grey[850] : Colors.white,
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white : Colors.black,
              ),
              items:
                  editorList
                      .where((e) => e != "All Editors")
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: GoogleFonts.cairo()),
                        ),
                      )
                      .toList(),
              onChanged: (v) {
                if (v != null) sel.value = v;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtl,
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Note",
                filled: true,
                fillColor: isDark ? Colors.black12 : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        );
      }),
      confirm: ElevatedButton(
        onPressed: () async {
          if (sel.value.isEmpty) return;
          await API.patchData("SubTasks/$subTaskId", [
            {"op": "replace", "path": "/editor", "value": sel.value},
            {"op": "replace", "path": "/note", "value": noteCtl.text.trim()},
          ]);
          await fetchSubTasks();
          Get.back();
        },
        child: Text(
          "Save",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("Cancel", style: GoogleFonts.cairo(color: Colors.red)),
      ),
    );
  }

  /// حوار تعديل الحالة
  Future<void> showStatusPopup(BuildContext context, int subTaskId) async {
    final RxString selectedStatus = ''.obs;
    final isDark = Get.isDarkMode;

    await Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Change Status",
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Obx(() {
          return DropdownButton<String>(
            isExpanded: true,
            value: selectedStatus.value.isEmpty ? null : selectedStatus.value,
            hint: Text(
              "Select new status",
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            dropdownColor: isDark ? Colors.grey[850] : Colors.white,
            style: GoogleFonts.cairo(
              color: isDark ? Colors.white : Colors.black,
            ),
            items:
                statusList
                    .where((s) => s != "All Statuses")
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status, style: GoogleFonts.cairo()),
                      ),
                    )
                    .toList(),
            onChanged: (newStatus) async {
              if (newStatus != null) {
                selectedStatus.value = newStatus;
                await updateSubTaskField(
                  subTaskId: subTaskId,
                  field: 'status',
                  newValue: newStatus,
                );
                Get.back();
              }
            },
          );
        }),
      ),
    );
  }

  /// حوار تعديل الملاحظة
  Future<void> showNotePopup(
    BuildContext context,
    int subTaskId,
    String current,
  ) async {
    final isDark = Get.isDarkMode;
    final noteCtl = TextEditingController()..text = current;

    await Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Edit Note",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: TextField(
          controller: noteCtl,
          maxLines: 3,
          style: GoogleFonts.cairo(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Enter note",
            filled: true,
            fillColor: isDark ? Colors.black12 : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: GoogleFonts.cairo(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateSubTaskField(
                subTaskId: subTaskId,
                field: 'note',
                newValue: noteCtl.text.trim(),
              );
              Get.back();
            },
            child: Text(
              "Save",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// حوار إضافة/تعديل روابط
  Future<void> showLinkDialog(BuildContext context, int subTaskId) async {
    final isDark = Get.isDarkMode;
    List<TextEditingController> linkCtrls = [TextEditingController()];
    RxString errorText = ''.obs;

    await Get.defaultDialog(
      title: "Add/Edit Link(s)",
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      radius: 16,
      content: StatefulBuilder(
        builder: (ctx, setState) {
          return Obx(() {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...linkCtrls.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextField(
                        controller: c,
                        style: GoogleFonts.cairo(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "https://galleries.vidflow.co/…",
                          filled: true,
                          fillColor: isDark ? Colors.black12 : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed:
                        () => setState(
                          () => linkCtrls.add(TextEditingController()),
                        ),
                    icon: const Icon(Icons.add),
                    label: Text("Add Another Link", style: GoogleFonts.cairo()),
                  ),
                  if (errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        errorText.value,
                        style: GoogleFonts.cairo(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          });
        },
      ),
      confirm: ElevatedButton.icon(
        icon: const Icon(Icons.send),
        label: Text(
          "Submit",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final links =
              linkCtrls
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
            await API.patchData("SubTasks/$subTaskId", [
              {"op": "replace", "path": "/links", "value": joined},
            ]);
            await fetchSubTasks();
            Get.back();
          } catch (_) {
            errorText.value = "❌ Failed to send link(s). Try again.";
          }
        },
      ),
    );
  }

  /// حذف SubTask واحد
  Future<void> deleteSubTask(int subTaskId) async {
    final confirmed = await Get.defaultDialog<bool>(
      title: "Confirm Deletion",
      content: const Text("Are you sure you want to delete this sub-task?"),
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    if (confirmed == true) {
      final resp = await API.deleteData("SubTasks/$subTaskId");
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        await fetchSubTasks();
        Get.snackbar(
          "Deleted",
          "Sub-task deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }

  /// حذف مجموعة مختارة من SubTasks
  Future<void> deleteSelectedSubTasks() async {
    for (final id in selectedSubTaskIds) {
      await deleteSubTask(id);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    selectedSubTaskIds.clear();
  }

  /// تبديل اختيار SubTask
  void toggleSubTaskSelection(int subTaskId) {
    if (selectedSubTaskIds.contains(subTaskId)) {
      selectedSubTaskIds.remove(subTaskId);
    } else {
      selectedSubTaskIds.add(subTaskId);
    }
    update();
  }

  /// تحديد كل SubTasks في القائمة
  void toggleSelectAllSubTasks(List<SubTaskModel> subs) {
    final allIds = subs.map((e) => e.id).toList();
    if (selectedSubTaskIds.length == allIds.length) {
      selectedSubTaskIds.clear();
    } else {
      selectedSubTaskIds.assignAll(allIds);
    }
    update();
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
}
