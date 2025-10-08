import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio;
import '../api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AttendanceController extends GetxController {
  final box = GetStorage();

  var isLoading = false.obs;
  var attendanceRecords = [].obs;
  var errorMessage = ''.obs;
  String? token;
  List users = [];

  // أوقات الحضور والانصراف
  Rx<TimeOfDay> checkInTime = TimeOfDay(hour: 8, minute: 0).obs;
  Rx<TimeOfDay> checkOutTime = TimeOfDay(hour: 17, minute: 0).obs;

  // صفحة الرسم البياني (كل صفحة = 14 يوم)
  RxInt chartPage = 0.obs;

  AttendanceController() {
    _loadReferenceTimes();
  }

  Future<void> _loadReferenceTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final checkInStr = prefs.getString('checkInTime');
    final checkOutStr = prefs.getString('checkOutTime');
    if (checkInStr != null) {
      final parts = checkInStr.split(':');
      if (parts.length == 2) {
        checkInTime.value = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    if (checkOutStr != null) {
      final parts = checkOutStr.split(':');
      if (parts.length == 2) {
        checkOutTime.value = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
  }

  Future<void> saveAttendanceTimes(TimeOfDay inTime, TimeOfDay outTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('checkInHour', inTime.hour);
    await prefs.setInt('checkInMinute', inTime.minute);
    await prefs.setInt('checkOutHour', outTime.hour);
    await prefs.setInt('checkOutMinute', outTime.minute);
    checkInTime.value = inTime;
    checkOutTime.value = outTime;
  }

  Future<void> fetchAttendanceRecords() async {
    isLoading.value = true;
    errorMessage.value = '';
    token = box.read('token');
    try {
      if (token == null) {
        errorMessage.value = 'User not authenticated.';
        isLoading.value = false;
        return;
      }
      final options = dio.Options(headers: {'Authorization': 'Bearer $token'});
      // جلب المستخدمين أولاً
      final usersResponse = await API.getData(EndPoints.users, options: options);
      if (usersResponse.statusCode == 200 && usersResponse.data is List) {
        users = usersResponse.data;
      } else {
        users = [];
      }
      // جلب سجلات الحضور
      final response = await API.getData(EndPoints.attendanceHistory, options: options);
      if (response.statusCode == 200 && response.data is List) {
        // ربط كل سجل حضور بصورة المستخدم
        List records = response.data;
        for (var record in records) {
          final user = users.firstWhereOrNull((u) => u['id'] == record['userId']);
          record['imageUrl'] = user != null ? user['imageUrl'] : null;
        }
        attendanceRecords.value = records;
      } else {
        attendanceRecords.value = [];
        errorMessage.value = 'Failed to load attendance records.';
      }
    } catch (e) {
      errorMessage.value = 'Error:  ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // --- إحصائيات جاهزة للاستخدام في الواجهة ---
  int get totalEmployees => attendanceRecords.length;
  int get checkedIn => attendanceRecords.where((r) => r['checkIn'] != null).length;
  int get absent => attendanceRecords.where((r) => r['checkIn'] == null).length;
  int get lateArrival {
    // إذا لم يحدد المستخدم وقت حضور، لا يوجد متأخرين
    if (checkInTime.value.hour == 0 && checkInTime.value.minute == 0) return 0;
    return attendanceRecords.where((r) {
      if (r['checkIn'] == null) return false;
      final checkInStr = r['checkIn'].toString();
      final checkInTimeParts = checkInStr.split('T');
      if (checkInTimeParts.length < 2) return false;
      final timeParts = checkInTimeParts[1].split(':');
      if (timeParts.length < 2) return false;
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final userCheckIn = TimeOfDay(hour: hour, minute: minute);
      // إذا وقت الحضور بعد الوقت المحدد
      return (userCheckIn.hour > checkInTime.value.hour) ||
             (userCheckIn.hour == checkInTime.value.hour && userCheckIn.minute > checkInTime.value.minute);
    }).length;
  }

  int get earlyDeparture {
    // إذا لم يحدد المستخدم وقت انصراف، لا يوجد مبكرين
    if (checkOutTime.value.hour == 0 && checkOutTime.value.minute == 0) return 0;
    return attendanceRecords.where((r) {
      if (r['checkOut'] == null) return false;
      final checkOutStr = r['checkOut'].toString();
      final checkOutTimeParts = checkOutStr.split('T');
      if (checkOutTimeParts.length < 2) return false;
      final timeParts = checkOutTimeParts[1].split(':');
      if (timeParts.length < 2) return false;
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final userCheckOut = TimeOfDay(hour: hour, minute: minute);
      // إذا وقت الانصراف قبل الوقت المحدد
      return (userCheckOut.hour < checkOutTime.value.hour) ||
             (userCheckOut.hour == checkOutTime.value.hour && userCheckOut.minute < checkOutTime.value.minute);
    }).length;
  }

  // بيانات الرسم البياني (الحضور اليومي لآخر 14 يوم)
  List<Map<String, dynamic>> getAttendanceChartData({int page = 0}) {
    final now = DateTime.now();
    // كل صفحة = 14 يوم، page=0 تعني آخر 14 يوم، page=1 تعني 14 يوم قبلها...
    final start = now.subtract(Duration(days: 14 * page));
    return List.generate(14, (i) {
      final day = start.subtract(Duration(days: 13 - i));
      final dayStr = day.toString().substring(0, 10);
      final count = attendanceRecords.where((r) => (r['checkIn'] ?? '').toString().startsWith(dayStr)).length;
      return {'date': dayStr, 'count': count};
    });
  }

  Future<void> setCheckInTime(TimeOfDay time) async {
    checkInTime.value = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('checkInTime', '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
  }

  Future<void> setCheckOutTime(TimeOfDay time) async {
    checkOutTime.value = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('checkOutTime', '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
  }
} 