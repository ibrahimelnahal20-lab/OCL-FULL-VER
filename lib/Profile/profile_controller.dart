// lib/controllers/profile_controller.dart

import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:ocl2/API/API.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:ocl2/routes/routes.dart';

class ProfileController extends GetxController {
  // Text controllers for profile fields
  final usernameController = TextEditingController();
  final jobTitleController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  // Text controllers for password change
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observables
  final userType = ''.obs;
  final imageUrl = ''.obs;
  final userId = 0.obs;
  final isLoading = true.obs;
  final selectedImageBytes = Rx<Uint8List?>(null);
  final isChangingPassword = false.obs;
  final isSavingProfile = false.obs;
  final newPasswordText = "".obs;

  // للحصول على اسم المستخدم المسجّل حالياً
  final topBarController = Get.find<TopBarController>();

  void updateNewPasswordText(String text) {
    newPasswordText.value = text;
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  /// يفتح نافذة اختيار صورة ويب ثم يرفعها على API
  Future<void> pickImage() async {
    final mediaInfo = await ImagePickerWeb.getImageInfo();
    if (mediaInfo == null) return;
    selectedImageBytes.value = mediaInfo.data;

    final multipart = dio.MultipartFile.fromBytes(
      mediaInfo.data!,
      filename: mediaInfo.fileName ?? 'avatar.png',
    );
    await _sendImageToAPI(multipart);
  }

  Future<void> _sendImageToAPI(dio.MultipartFile imageFile) async {
    try {
      final resp = await API.patchImageWeb(
        "Users/UpdateImage/${userId.value}",
        imageFile,
      );
      if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
        // تحديث المسار محليًا
        imageUrl.value = resp.data['imageUrl'] ?? imageUrl.value;
        // مربع الحوار مع رسالة إعادة تسجيل الدخول
        _showDialog(
          title: "Success",
          message:
              "Profile image updated successfully.\nPlease log out and log in again to see the changes on the web.",
          success: true,
        );
      } else {
        _showDialog(
          title: "Error",
          message: "Failed to update profile image.",
          success: false,
        );
      }
    } catch (e) {
      // Removed debug print for security
      _showDialog(
        title: "Error",
        message: "Failed to update profile image.",
        success: false,
      );
    }
  }

  /// جلب بيانات الملف الشخصي للمستخدم المسجّل
  Future<void> fetchUserProfile() async {
    try {
      final username = topBarController.loggedInUsername.value;
      final resp = await API.getData("Users");
      if (resp.statusCode == 200 && resp.data is List) {
        final matched = (resp.data as List).firstWhere(
          (u) => u["username"] == username,
          orElse: () => null,
        );
        if (matched != null) {
          userId.value = matched["id"];
          usernameController.text = matched["username"] ?? "";
          jobTitleController.text = matched["jobTitle"] ?? "";
          phoneController.text = matched["phone"] ?? "";
          descriptionController.text = matched["description"] ?? "";
          userType.value = matched["userType"] ?? "";
          imageUrl.value = matched["imageUrl"] ?? "";
        }
      }
    } catch (e) {
      // Removed debug print for security
      _showDialog(
        title: "Error",
        message: "Failed to load profile data.",
        success: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// حفظ التعديلات النصّية باستخدام JSON‑Patch (بدون كلمة المرور)
  Future<void> saveProfileChanges() async {
    // Prevent duplicate calls
    if (isSavingProfile.value) return;

    try {
      isSavingProfile.value = true;

      final updated = {
        "username": usernameController.text,
        "jobTitle": jobTitleController.text,
        "phone": phoneController.text,
        "description": descriptionController.text,
      };
      await API.patchData(
        "Users/${userId.value}",
        updated.entries
            .map(
              (e) => {"op": "replace", "path": "/${e.key}", "value": e.value},
            )
            .toList(),
      );
      _showDialog(
        title: "Success",
        message: "Profile updated successfully.",
        success: true,
      );
    } catch (e) {
      // Removed debug print for security
      _showDialog(
        title: "Error",
        message: "Failed to update profile.",
        success: false,
      );
    } finally {
      isSavingProfile.value = false;
    }
  }

  /// تغيير كلمة المرور باستخدام endpoint منفصل
  Future<void> changePassword() async {
    // Prevent duplicate calls
    if (isChangingPassword.value) return;

    // التحقق من صحة المدخلات
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showDialog(
        title: "Error",
        message: "Please fill in all password fields.",
        success: false,
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showDialog(
        title: "Error",
        message: "New password and confirm password do not match.",
        success: false,
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      _showDialog(
        title: "Error",
        message: "New password must be at least 6 characters long.",
        success: false,
      );
      return;
    }

    try {
      isChangingPassword.value = true;

      final passwordData = {
        "currentPassword": currentPasswordController.text,
        "newPassword": newPasswordController.text,
        "confirmNewPassword": confirmPasswordController.text,
      };

      final resp = await API.postData("Auth/change-password", passwordData);

      if (resp.statusCode == 200) {
        _showDialog(
          title: "Success",
          message: "Password changed successfully.",
          success: true,
        );
        // مسح حقول كلمة المرور
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      } else {
        _showDialog(
          title: "Error",
          message:
              "Failed to change password. Please check your current password.",
          success: false,
        );
      }
    } catch (e) {
      // Removed debug print for security
      _showDialog(
        title: "Error",
        message: "Failed to change password. Please try again.",
        success: false,
      );
    } finally {
      isChangingPassword.value = false;
    }
  }

  /// Navigate back to home page
  void goBackToHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  /// مربع حوار موحّد للنجاح/الفشل مع تصميم أفضل
  void _showDialog({
    required String title,
    required String message,
    bool success = true,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: success ? Colors.green : Colors.redAccent,
      ),
      content: Column(
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.error_outline,
            size: 48,
            color: success ? Colors.green : Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Get.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
      backgroundColor: Get.isDarkMode ? Colors.grey.shade800 : Colors.white,
      radius: 16,
      barrierDismissible: false,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: success ? Colors.green : Colors.redAccent,
      onConfirm: () => Get.back(),
    );
  }

  @override
  void onClose() {
    usernameController.dispose();
    jobTitleController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
