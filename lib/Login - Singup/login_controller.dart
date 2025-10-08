// ignore_for_file: file_names, unnecessary_overrides

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

import 'package:ocl2/api/api.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:ocl2/routes/routes.dart';
import 'package:ocl2/widgets/enhanced_snackbar.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final box = GetStorage();

  // يمكنك استخدام Get.find() في الواجهة بدلاً من تعريفها هنا
  // final TopBarController topBarController = Get.put(TopBarController());

  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // هذه الدالة الآن ستحمل اسم المستخدم فقط إذا كان محفوظاً
    _loadSavedCredentials();
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  // تم تعديل الدالة لتستقبل قيمة من الواجهة
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  // --- 1. دالة تسجيل الدخول الجديدة والآمنة ---
  void login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (!_validateInput(username, password)) return;

    isLoading.value = true;
    try {
      // استدعاء نقطة النهاية الجديدة والآمنة
      final response = await API.postData(EndPoints.login, {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;
        final user = responseData['user'];
        final String token = responseData['token'];

        // حفظ بيانات الجلسة الجديدة (بما في ذلك التوكن)
        _saveCredentials(user, token);

        // تسجيل الحضور تلقائياً بعد الحصول على التوكن
        await _checkIn(token);

        // تحديث الشريط العلوي
        if (Get.isRegistered<TopBarController>()) {
          final topBarController = Get.find<TopBarController>();
          topBarController.setUsername(user['username']);
          topBarController.setUserType(user['userType'] ?? 'user');
          topBarController.setUserImage(user['imageUrl'] ?? '');
        }

        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      if (kDebugMode) print("Login failed in controller: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 2. دالة جديدة لتسجيل الخروج والانصراف ---
  Future<void> signOutAndCheckOut() async {
    isLoading.value = true;
    final token = box.read('token');

    if (token != null) {
      try {
        // تسجيل الانصراف أولاً
        await API.putData(
          EndPoints.checkOut,
          {},
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        if (kDebugMode) print(">>> ATTENDANCE: Checked OUT successfully.");
      } catch (e) {
        if (kDebugMode) print(">>> ATTENDANCE: Check-out FAILED: $e");
      }
    }

    // هذه هي الدالة الوحيدة التي تمسح كل شيء
    _clearAllSessionData();
    isLoading.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  // --- 3. الدوال المساعدة ---

  Future<void> _checkIn(String token) async {
    try {
      await API.postData(
        EndPoints.checkIn,
        {},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (kDebugMode) print(">>> ATTENDANCE: Checked IN successfully.");
    } catch (e) {
      if (kDebugMode) print(">>> ATTENDANCE: Check-in FAILED: $e");
    }
  }

  // تم تعديل هذه الدالة لتحفظ التوكن بدلاً من كلمة المرور
  void _saveCredentials(Map<String, dynamic> user, String token) {
    box.write('token', token);
    box.write('isLoggedIn', true);
    box.write('lastPage', 'home'); // الحفاظ على وظيفتك القديمة
    box.write('userId', user['id']); // <-- إضافة: حفظ معرّف المستخدم دائماً

    if (rememberMe.value) {
      box.write('remember_me', true);
      box.write('saved_username', user['username']);
      // حفظ باقي البيانات إذا أردت
      box.write('saved_userType', user['userType']);
      box.write('saved_imageUrl', user['imageUrl']);
    } else {
      // إذا لم يكن يريد "تذكرني"، لا نحفظ بيانات التذكر
      _clearCredentials();
    }
  }

  // هذه الدالة الآن تمسح فقط بيانات "تذكرني"
  void _clearCredentials() {
    box.remove('saved_username');
    box.remove('saved_userType');
    box.remove('saved_imageUrl');
    box.write('remember_me', false);
  }

  // دالة جديدة لمسح كل شيء عند تسجيل الخروج
  void _clearAllSessionData() {
    box.erase();
  }

  // هذه الدالة الآن تبحث فقط عن اسم المستخدم المحفوظ
  void _loadSavedCredentials() {
    if (box.read('remember_me') == true) {
      usernameController.text = box.read('saved_username') ?? '';
      // لا نقوم بتحميل كلمة المرور لأنها غير مخزنة
      rememberMe.value = true;
    }
  }

  // --- دوال الواجهة (تبقى كما هي) ---

  bool _validateInput(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter both username and password.");
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    EnhancedSnackBar.showError(title: "Login Error", message: message);
  }
}
