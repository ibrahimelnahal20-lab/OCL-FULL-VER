// lib/Attendance/attendance_overview_controller.dart
// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:ocl2/Attendance/attendance_controller.dart';
import 'package:ocl2/api/api.dart';

class AttendanceOverviewController extends GetxController {
  final RxList<Map<String, dynamic>> _masterAttendanceList =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> displayedAttendanceList =
      <Map<String, dynamic>>[].obs;
  final RxnString error = RxnString();
  final TextEditingController searchController = TextEditingController();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt sortColumnIndex = 5.obs; // الفرز الافتراضي حسب عمود Check-in
  final RxBool isAscending = true.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalRecords = 0.obs;
  late AttendanceController _attendanceController;

  // Advanced filter state
  String? _filterEmployee;
  final Rx<String?> filterDepartment = Rx<String?>(null);
  final Rx<String?> filterStatus = Rx<String?>(null);
  final Rx<DateTimeRange?> filterDateRange = Rx<DateTimeRange?>(null);

  int rowsPerPage = 10;

  List<Map<String, dynamic>> users = [];
  List<String> get uniqueJobTitles =>
      users
          .map((u) => u['jobTitle']?.toString() ?? '')
          .toSet()
          .where((e) => e.isNotEmpty)
          .toList();

  void applyAdvancedFilters({
    String? employee,
    String? department,
    String? status,
    DateTimeRange? dateRange,
  }) {
    _filterEmployee =
        (employee != null && employee.trim().isNotEmpty)
            ? employee.trim().toLowerCase()
            : null;
    filterDepartment.value =
        (department != null && department.trim().isNotEmpty)
            ? department.trim().toLowerCase()
            : null;
    filterStatus.value =
        (status != null && status.trim().isNotEmpty) ? status.trim() : null;
    filterDateRange.value = dateRange;
    currentPage.value = 1;
    _processData();
  }

  void clearAdvancedFilters() {
    _filterEmployee = null;
    filterDepartment.value = null;
    filterStatus.value = null;
    filterDateRange.value = null;
    currentPage.value = 1;
    _processData();
  }

  void setRowsPerPage(int value) {
    rowsPerPage = value;
    currentPage.value = 1;
    _processData();
  }

  int get totalPages =>
      totalRecords.value == 0 ? 1 : (totalRecords.value / rowsPerPage).ceil();

  @override
  void onInit() {
    super.onInit();
    // Try to find AttendanceController, if not found, create it
    try {
      _attendanceController = Get.find<AttendanceController>();
    } catch (e) {
      _attendanceController = Get.put(AttendanceController());
    }
    fetchUsers();
    searchController.addListener(_processData);
    fetchData();
    ever(_attendanceController.checkInTime, (_) => _processData());
    ever(_attendanceController.checkOutTime, (_) => _processData());
  }

  @override
  void onClose() {
    searchController.removeListener(_processData);
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchData() async {
    isLoading(true);
    error(null);
    final box = GetStorage();
    final token = box.read<String>('token');
    if (token == null) {
      error.value = "Authentication Error: Not logged in.";
      isLoading(false);
      return;
    }
    try {
      final response = await API.getData(
        EndPoints.attendanceHistory,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      _masterAttendanceList.value = List<Map<String, dynamic>>.from(
        response.data,
      );
      _processData();
    } catch (e) {
      error.value = "An error occurred while fetching data: ${e.toString()}";
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await API.getData(EndPoints.users);
      users = List<Map<String, dynamic>>.from(response.data);
      _processData();
    } catch (e) {
      // ignore error for now
    }
  }

  void _processData() {
    List<Map<String, dynamic>> processedList = List.from(_masterAttendanceList);
    // 1. Search filter
    if (searchController.text.isNotEmpty) {
      String query = searchController.text.toLowerCase();
      processedList =
          processedList.where((record) {
            return (record['username']?.toString().toLowerCase().contains(
                      query,
                    ) ??
                    false) ||
                (record['jobTitle']?.toString().toLowerCase().contains(query) ??
                    false);
          }).toList();
    }
    // 2. Date filter (single day or range)
    if (filterDateRange.value != null) {
      processedList =
          processedList.where((record) {
            if (record['checkIn'] == null) return false;
            final recordDay = DateTime.parse(record['checkIn']).toLocal();
            return !recordDay.isBefore(filterDateRange.value!.start) &&
                !recordDay.isAfter(filterDateRange.value!.end);
          }).toList();
    } else {
      final selectedDay = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      processedList =
          processedList.where((record) {
            if (record['checkIn'] == null) return false;
            final recordDay = record['checkIn'].toString().substring(0, 10);
            return recordDay == selectedDay;
          }).toList();
    }
    // 3. Advanced filters
    if (_filterEmployee != null) {
      processedList =
          processedList
              .where(
                (record) =>
                    (record['username']?.toString().toLowerCase().contains(
                          _filterEmployee!,
                        ) ??
                        false),
              )
              .toList();
    }
    if (filterDepartment.value != null) {
      processedList =
          processedList
              .where(
                (record) =>
                    (record['jobTitle']?.toString().toLowerCase().contains(
                          filterDepartment.value!,
                        ) ??
                        false),
              )
              .toList();
    }
    if (filterStatus.value != null) {
      processedList =
          processedList.where((record) {
            final checkInDateTime =
                record['checkIn'] != null
                    ? DateTime.parse(record['checkIn']).toLocal()
                    : null;
            final status = _calculateStatus(checkInDateTime);
            return status == filterStatus.value;
          }).toList();
    }
    // 4. Mapping, sorting, and pagination as before
    final List<Map<String, dynamic>> mappedList =
        processedList.map((record) {
          final checkInDateTime =
              record['checkIn'] != null
                  ? DateTime.parse(record['checkIn']).toLocal()
                  : null;
          return {
            'no': (processedList.indexOf(record) + 1).toString(),
            'employee': record['username'] ?? 'N/A',
            'department': record['jobTitle'] ?? 'N/A',
            'date': _formatDate(record['checkIn']),
            'status': _calculateStatus(checkInDateTime),
            'check_in': _formatTime(record['checkIn']),
            'check_out': _formatTime(record['checkOut']),
            'work_hours': _calculateDuration(
              record['checkIn'],
              record['checkOut'],
            ),
            'early_late_by': calculateEarlyLateBy(checkInDateTime),
            'late_early_time': calculateLateEarlyTime(checkInDateTime),
            'check_in_raw': record['checkIn'],
          };
        }).toList();

    // 5. Add absentees (users with no attendance record for the selected date)
    final Set<String> presentUsernames =
        mappedList.map((r) => r['employee']?.toString() ?? '').toSet();

    // Create a set to track unique usernames to avoid duplicates
    final Set<String> addedAbsentees = {};

    for (final user in users) {
      final username = user['username']?.toString() ?? '';
      // Skip if username is empty, already present, or already added as absent
      if (username.isEmpty ||
          presentUsernames.contains(username) ||
          addedAbsentees.contains(username)) {
        continue;
      }

      addedAbsentees.add(username); // Mark this username as processed

      mappedList.add({
        'no': '',
        'employee': username,
        'department': user['jobTitle'] ?? 'N/A',
        'date':
            filterDateRange.value != null
                ? '${filterDateRange.value!.start.toLocal().toString().split(' ')[0]} - ${filterDateRange.value!.end.toLocal().toString().split(' ')[0]}'
                : DateFormat('d MMMM yyyy').format(selectedDate.value),
        'status': 'Absent',
        'check_in': '--',
        'check_out': '--',
        'work_hours': 'N/A',
        'early_late_by': '--',
        'late_early_time': '--',
        'check_in_raw': null,
      });
    }

    // Sort so that present employees come first, followed by absent ones
    mappedList.sort((a, b) {
      // First compare by status (present vs absent)
      if (a['status'] == 'Absent' && b['status'] != 'Absent') return 1;
      if (a['status'] != 'Absent' && b['status'] == 'Absent') return -1;

      // If both have same status (both present or both absent), use the column sorting
      final columns = [
        'no',
        'employee',
        'department',
        'date',
        'status',
        'check_in_raw',
        'check_out',
        'work_hours',
        'early_late_by',
      ];
      if (sortColumnIndex.value < columns.length) {
        final sortKey = columns[sortColumnIndex.value];
        final aValue = a[sortKey];
        final bValue = b[sortKey];
        if (aValue == null && bValue == null) return 0;
        if (aValue == null) return isAscending.value ? -1 : 1;
        if (bValue == null) return isAscending.value ? 1 : -1;
        final compare = Comparable.compare(
          aValue.toString(),
          bValue.toString(),
        );
        return isAscending.value ? compare : -compare;
      }
      return 0;
    });

    totalRecords.value = mappedList.length;
    _paginateList(mappedList);
  }

  void _paginateList(List<Map<String, dynamic>> list) {
    final int startIndex = (currentPage.value - 1) * rowsPerPage;
    int endIndex = startIndex + rowsPerPage;
    if (endIndex > list.length) endIndex = list.length;
    displayedAttendanceList.value =
        (startIndex >= list.length) ? [] : list.sublist(startIndex, endIndex);
  }

  void sortData(int columnIndex) {
    if (sortColumnIndex.value == columnIndex) {
      isAscending.value = !isAscending.value;
    } else {
      sortColumnIndex.value = columnIndex;
      isAscending.value = true;
    }
    _processData();
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
      _processData();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      _processData();
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      currentPage.value = 1;
      _processData();
    }
  }

  String get formattedSelectedDate =>
      DateFormat('d MMMM yyyy').format(selectedDate.value);

  // === دوال الحسابات المحسّنة ===
  String _calculateStatus(DateTime? checkIn) {
    if (checkIn == null) return 'Absent';
    final checkInTime = TimeOfDay.fromDateTime(checkIn);
    final refTime = _attendanceController.checkInTime.value;
    final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
    final refMinutes = refTime.hour * 60 + refTime.minute;
    if (checkInMinutes < refMinutes) return 'Early Arrival';
    if (checkInMinutes > refMinutes) return 'Late Arrival';
    return 'On Time';
  }

  String calculateEarlyLateBy(DateTime? checkIn) {
    if (checkIn == null) return '--';
    final refTime = _attendanceController.checkInTime.value;
    final refDateTime = DateTime(
      checkIn.year,
      checkIn.month,
      checkIn.day,
      refTime.hour,
      refTime.minute,
    );
    final difference = checkIn.difference(refDateTime);
    if (difference.inMinutes == 0) return 'On Time';
    final duration = difference.isNegative ? -difference : difference;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final status = difference.isNegative ? 'Early' : 'Late';
    if (hours == 0) return '$minutes m $status';
    return '${hours}h ${minutes}m $status';
  }

  String calculateLateEarlyTime(DateTime? checkIn) {
    if (checkIn == null) return 'N/A';

    final refTime = _attendanceController.checkInTime.value;
    final refDateTime = DateTime(
      checkIn.year,
      checkIn.month,
      checkIn.day,
      refTime.hour,
      refTime.minute,
    );

    final difference = checkIn.difference(refDateTime);
    final totalMinutes = difference.inMinutes;

    if (totalMinutes == 0) return 'On Time';

    final isLate = totalMinutes > 0;
    final absMinutes = totalMinutes.abs();
    final hours = absMinutes ~/ 60;
    final minutes = absMinutes % 60;

    String timeString = '';

    if (hours > 0) {
      timeString += '${hours}h';
      if (minutes > 0) {
        timeString += ' ${minutes}m';
      }
    } else {
      timeString += '${minutes}m';
    }

    return isLate ? '$timeString Late' : '$timeString Early';
  }

  // --- دوال مساعدة للتنسيق ---
  String _formatDate(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      return DateFormat(
        'd MMMM yyyy',
      ).format(DateTime.parse(isoString).toLocal());
    } catch (e) {
      return 'Invalid';
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '--:--';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(isoString).toLocal());
    } catch (e) {
      return 'Invalid';
    }
  }

  String _calculateDuration(String? checkIn, String? checkOut) {
    if (checkIn == null || checkOut == null) return '0m';
    try {
      final duration = DateTime.parse(
        checkOut,
      ).difference(DateTime.parse(checkIn));
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } catch (e) {
      return 'Error';
    }
  }
}
