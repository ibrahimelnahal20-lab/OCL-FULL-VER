// lib/widgets/Notification/notification_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ocl2/API/api.dart';

enum TaskStatus { notStarted, inProgress, complete, canceled, unknown }

/// نموذج SubTask داخل نفس الملف
class SubTaskModel {
  final String name;
  final String startDate;
  final String deadlineDate;
  final String editor;
  final String status;
  final String note;

  SubTaskModel({
    required this.name,
    required this.startDate,
    required this.deadlineDate,
    required this.editor,
    required this.status,
    required this.note,
  });

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      name: json['name'] ?? '',
      startDate: json['startDate'] ?? '',
      deadlineDate: json['deadlineDate'] ?? '',
      editor: json['editor'] ?? '',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
    );
  }
}

class NotificationController extends GetxController {
  // إشعارات Task
  final RxList<Map<String, String>> notifications = <Map<String, String>>[].obs;
  // إشعارات SubTask
  final RxList<SubTaskModel> subNotifications = <SubTaskModel>[].obs;

  // مفاتيح المهام المحذوفة (لمنع إعادة الظهور)
  final RxList<String> deletedKeys = <String>[].obs;

  // فلترة حسب الحالة
  final RxString selectedStatus = 'All Statuses'.obs;
  void setSelectedStatus(String s) => selectedStatus.value = s;

  // اختيار Task أو SubTask
  final RxString selectedType = 'Task'.obs;
  void setSelectedType(String t) => selectedType.value = t;

  // عدادات لكل نوع
  final RxInt taskCount = 0.obs;
  final RxInt subTaskCount = 0.obs;

  final GetStorage box = GetStorage();
  Timer? _notificationTimer;
  String get username => box.read<String>('loggedInUsername') ?? 'Unknown User';

  @override
  void onInit() {
    super.onInit();
    _autoCleanup();
    deletedKeys.assignAll(List<String>.from(box.read('deletedTasks') ?? []));
    _loadAll();
  }

  @override
  void onClose() {
    _notificationTimer?.cancel();
    super.onClose();
  }

  /// تنظيف مفاتيح المحذوفات كل يومين
  void _autoCleanup() {
    final last = box.read<String>('lastDeletedCleanup');
    final now = DateTime.now();
    if (last != null) {
      final prev = DateTime.tryParse(last);
      if (prev != null && now.difference(prev).inDays >= 2) {
        box.remove('deletedTasks');
        box.write('lastDeletedCleanup', now.toIso8601String());
      }
    } else {
      box.write('lastDeletedCleanup', now.toIso8601String());
    }
  }

  void _loadAll() {
    fetchNotifications();
    fetchSubTasks();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchNotifications();
      fetchSubTasks();
    });
  }

  /// جلب إشعارات Task وفلترتها حسب اسم المستخدم ضمن projectManager
  Future<void> fetchNotifications() async {
    try {
      final response = await API.getData(EndPoints.task);
      if (response.statusCode == 200 && response.data is List) {
        final raw = response.data as List<dynamic>;
        notifications.assignAll(_extractUserNotifications(raw));
        _updateCounts();
      }
    } catch (e) {
      _showWarning("Error", "Failed to fetch notifications:\n$e");
    }
  }

  List<Map<String, String>> _extractUserNotifications(List<dynamic> data) {
    final seen = <String>{};
    final result = <Map<String, String>>[];

    for (var item in data) {
      final t = item as Map<String, dynamic>;
      final taskName = t["taskName"] as String? ?? "Unnamed Task";
      final startDate = t["taskStartDate"] as String? ?? "No start date";
      final key = "$taskName-$startDate";

      // تجزئة projectManager بفواصل أو شرطات وإزالة النقطتين
      final rawManagers = t["projectManager"] as String? ?? "";
      final managers =
          rawManagers
              .split(RegExp(r'\s*[-,]\s*'))
              .map((e) => e.replaceAll(':', '').trim())
              .where((e) => e.isNotEmpty)
              .toList();

      // تأكد أن المستخدم موجود ضمن المدراء
      final idx = managers.indexOf(username);
      if (idx == -1) continue;

      if (!seen.add(key) || deletedKeys.contains(key)) continue;

      // بناء خريطة الملاحظات من noteManager: "Name: note"
      final rawNotes = (t["noteManager"] as String? ?? "").split(
        RegExp(r'\s*,\s*'),
      );
      final noteMap = <String, String>{};
      for (var part in rawNotes) {
        final split = part.split(":");
        if (split.length >= 2) {
          final mgr = split[0].trim();
          final txt = split.sublist(1).join(":").trim();
          if (mgr.isNotEmpty) noteMap[mgr.replaceAll(':', '')] = txt;
        }
      }
      final userNote = noteMap[username] ?? "No notes available";

      result.add({
        "taskName": taskName,
        "taskStatus": t["taskStatus"] as String? ?? "Not started",
        "startDate": startDate,
        "deadline": t["taskDeadLine"] as String? ?? "No deadline",
        "note": userNote,
        "projectManager": rawManagers,
        "createdBy": t["createdBy"] as String? ?? "Unknown",
      });
    }

    return result;
  }

  /// جلب إشعارات SubTask وفلترتها حسب editor == المستخدم
  Future<void> fetchSubTasks() async {
    try {
      final response = await API.getData("SubTasks");
      if (response.statusCode == 200 && response.data is List) {
        final raw = response.data as List<dynamic>;
        final list =
            raw
                .map((e) => SubTaskModel.fromJson(e as Map<String, dynamic>))
                .where((s) => s.editor == username)
                .where((s) {
                  final key = '${s.name}-${s.startDate}';
                  return !deletedKeys.contains(key);
                })
                .toList();
        subNotifications.assignAll(list);
        _updateCounts();
      }
    } catch (e) {
      _showWarning("Error", "Failed to fetch subtasks:\n$e");
    }
  }

  void _updateCounts() {
    taskCount.value = notifications.length;
    subTaskCount.value = subNotifications.length;
  }

  TaskStatus _parseStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'not started':
        return TaskStatus.notStarted;
      case 'in progress':
        return TaskStatus.inProgress;
      case 'complete':
        return TaskStatus.complete;
      case 'canceled':
      case 'cancelled':
        return TaskStatus.canceled;
      default:
        return TaskStatus.unknown;
    }
  }

  List<dynamic> get filteredNotifications {
    final list =
        selectedType.value == 'Task' ? notifications : subNotifications;
    if (selectedStatus.value == 'All Statuses') return list;
    final filter = _parseStatus(selectedStatus.value);
    return list.where((item) {
      final status =
          item is Map<String, String>
              ? item['taskStatus']!
              : (item as SubTaskModel).status;
      return _parseStatus(status) == filter;
    }).toList();
  }

  /// حذف إشعار مفرد إذا كان مكتمل أو ملغي
  void removeNotification(int index) {
    if (index < 0 || index >= notifications.length) return;

    final status = notifications[index]["taskStatus"]!.toLowerCase();
    if (status == "complete" || status == "canceled") {
      final key =
          '${notifications[index]["taskName"]}-${notifications[index]["startDate"]}';
      deletedKeys.add(key);
      box.write('deletedTasks', deletedKeys.toList());
      notifications.removeAt(index);
    } else {
      _showWarning(
        "Cannot Delete",
        "You can only remove tasks that are Complete or Canceled.",
      );
    }
    _updateCounts();
  }

  /// مسح جميع الإشعارات المكتملة أو الملغاة
  void clearCompleted() {
    for (var task in notifications) {
      final st = _parseStatus(task["taskStatus"]);
      if (st == TaskStatus.complete || st == TaskStatus.canceled) {
        deletedKeys.add('${task["taskName"]}-${task["startDate"]}');
      }
    }
    box.write('deletedTasks', deletedKeys.toList());
    notifications.removeWhere((task) {
      final st = _parseStatus(task["taskStatus"]);
      return st == TaskStatus.complete || st == TaskStatus.canceled;
    });
    _updateCounts();
  }

  void _showWarning(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("OK")),
        ],
      ),
    );
  }

  void resetDeletedKeys() {
    deletedKeys.clear();
    box.remove('deletedTasks');
    box.remove('lastDeletedCleanup');
    _updateCounts();
  }
}
