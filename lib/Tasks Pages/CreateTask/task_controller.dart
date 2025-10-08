import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/API/api.dart';
import 'package:intl/intl.dart';

class TaskController extends GetxController {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  final RxList<Map<String, dynamic>> packageList = <Map<String, dynamic>>[].obs;
  final RxString selectedPackage = ''.obs;
  final RxString packageDescription = ''.obs;

  final RxList<String> selectedExtras = <String>[].obs;
  final List<String> extrasOptions = [
    "Documentary",
    "Reel",
    "Highlight",
    "Stories",
    "drone",
  ];

  final RxList<String> availableManagers = <String>[].obs;
  final RxList<String> selectedManagers = <String>[].obs;
  final RxMap<String, TextEditingController> managerNotes =
      <String, TextEditingController>{}.obs;

  late String createdByUser;

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
    fetchManagers();
    getCurrentUser();
  }

  void getCurrentUser() {
    final box = GetStorage();
    createdByUser = box.read<String>('loggedInUsername') ?? "Unknown User";
  }

  Future<void> fetchPackages() async {
    try {
      final response = await API.getData(EndPoints.package);
      packageList.assignAll(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      debugPrint("❌ فشل في جلب الباكدجات: $e");
    }
  }

  Future<void> fetchManagers() async {
    try {
      final response = await API.getData(EndPoints.users);

      // ✅ جلب كل المستخدمين بدون فلترة
      final allUsers =
          response.data
              .map<String>((user) => user["username"] as String)
              .toList();

      availableManagers.assignAll(allUsers);

      // ✅ إضافة خيار "Assign later" إذا لم يكن موجودًا
      if (!availableManagers.contains("Assign later")) {
        availableManagers.add("Assign later");
      }
    } catch (e) {
      debugPrint("❌ فشل في جلب قائمة المستخدمين: $e");
    }
  }

  void setSelectedPackage(String packageName) {
    selectedPackage.value = packageName;
    final package = packageList.firstWhereOrNull(
      (p) => p["packageName"] == packageName,
    );
    packageDescription.value =
        package?["packageDescription"] ?? "No description available";
  }

  void toggleExtra(String extra) {
    selectedExtras.contains(extra)
        ? selectedExtras.remove(extra)
        : selectedExtras.add(extra);
  }

  void addManager(String name) {
    if (name.isNotEmpty &&
        !selectedManagers.contains(name) &&
        selectedManagers.length < 2) {
      selectedManagers.add(name);
      managerNotes[name] = TextEditingController();
    }
  }

  void removeManager(String name) {
    selectedManagers.remove(name);
    managerNotes.remove(name);
  }

  void formatDateInput(TextEditingController controller, String value) {
    String cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedValue.length > 8) return;

    String formattedDate = '';
    for (int i = 0; i < cleanedValue.length; i++) {
      formattedDate += cleanedValue[i];
      if ((i == 1 || i == 3) && i != cleanedValue.length - 1) {
        formattedDate += '/';
      }
    }

    controller.value = TextEditingValue(
      text: formattedDate,
      selection: TextSelection.collapsed(offset: formattedDate.length),
    );
  }

  Future<void> pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }

  Future<void> createTask() async {
    if (projectNameController.text.isEmpty ||
        startDateController.text.isEmpty ||
        deadlineController.text.isEmpty ||
        selectedPackage.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all required fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final managerToSend =
        selectedManagers.isEmpty
            ? "Assign later"
            : selectedManagers.join(" - ");

    final noteToSend = selectedManagers
        .map((e) => "${e.trim()}: ${managerNotes[e]?.text ?? ''}")
        .join(", ");

    final taskData = {
      "taskID": 0,
      "taskName": projectNameController.text,
      "taskStartDate": formatDate(startDateController.text),
      "taskDeadLine": formatDate(deadlineController.text),
      "taskStatus": "Not started",
      "packages": selectedPackage.value,
      "extras": selectedExtras.join(", "),
      "projectManager": managerToSend,
      "noteManager": noteToSend,
      "createdBy": createdByUser,
    };

    try {
      await API.postData(EndPoints.task, taskData);
      _showSuccessDialog();
      _clearFields();
    } catch (e) {
      debugPrint("❌ فشل في إنشاء المهمة: $e");
      Get.snackbar(
        "Error",
        "Failed to create task",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String formatDate(String inputDate) {
    try {
      DateTime date = DateFormat("dd/MM/yyyy").parseStrict(inputDate);
      return DateFormat("yyyy-MM-dd").format(date);
    } catch (e) {
      debugPrint("❌ خطأ في تنسيق التاريخ: $e");
      return inputDate;
    }
  }

  void _showSuccessDialog() {
    Get.defaultDialog(
      title: "Success",
      titleStyle: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
      middleText: "The task has been created successfully!",
      middleTextStyle: TextStyle(fontSize: 16, color: Colors.black87),
      backgroundColor: Colors.white,
      radius: 10,
      contentPadding: const EdgeInsets.all(20),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text(
          "OK",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _clearFields() {
    projectNameController.clear();
    startDateController.clear();
    deadlineController.clear();
    selectedPackage.value = "";
    packageDescription.value = "";
    selectedExtras.clear();
    selectedManagers.clear();
    managerNotes.clear();
  }

  @override
  void onClose() {
    projectNameController.dispose();
    startDateController.dispose();
    deadlineController.dispose();
    for (var controller in managerNotes.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
