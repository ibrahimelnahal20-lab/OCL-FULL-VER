// ✅ SignupController.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:ocl2/API/API.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:ocl2/widgets/enhanced_snackbar.dart';

class SignupController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  final RxString usernameError = "".obs;
  final RxString phoneError = "".obs;
  final RxString jobTitleError = "".obs;
  final RxString passwordMatchError = "".obs;
  final RxString passwordText = "".obs;

  final box = GetStorage();

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  void updatePasswordText(String text) {
    passwordText.value = text;
  }

  void signup() async {
    if (!_validateInput()) return;

    isLoading.value = true;
    usernameError.value = "";
    phoneError.value = "";
    jobTitleError.value = "";
    passwordMatchError.value = "";

    try {
      // ✅ تحميل الصورة من assets وتحويلها إلى MultipartFile
      ByteData byteData = await rootBundle.load('assets/icons/dfa.jpg');
      List<int> imageBytes = byteData.buffer.asUint8List();
      MultipartFile imageFile = MultipartFile.fromBytes(
        imageBytes,
        filename: 'dfa.jpg',
      );

      final formData = FormData.fromMap({
        "username": usernameController.text.trim(),
        "password": passwordController.text.trim(),
        "userType": "user",
        "jobTitle": jobTitleController.text.trim(),
        "phone": phoneController.text.trim(),
        "description": "string",
        "imageFile": imageFile,
      });

      final response = await API.postData("Users", formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ تفريغ الحقول بعد النجاح
        usernameController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        jobTitleController.clear();
        phoneController.clear();
        box.write('lastPage', 'signup');
        Get.defaultDialog(
          title: "Success",
          titleStyle: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          middleText: "Account created successfully!",
          middleTextStyle: TextStyle(
            fontSize: 16,
            color: Get.isDarkMode ? Colors.white70 : Colors.black87,
          ),
          backgroundColor:
              Get.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          radius: 10,
          contentPadding: const EdgeInsets.all(20),
          confirm: ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        );
      } else if (response.statusCode == 400) {
        _handleApiError(response.data);
      } else {
        _showErrorDialog(
          "Phone number is already in use or Username is already taken.",
        );
      }
    } catch (e) {
      _handleApiError(null);
    }

    isLoading.value = false;
  }

  void _handleApiError(dynamic data) {
    List<String> errors = [];

    if (data is Map<String, dynamic> && data.containsKey('message')) {
      String errorMessage = data['message'];

      if (errorMessage.contains("Phone number is already in use")) {
        phoneError.value = "This phone number is already registered.";
        errors.add(phoneError.value);
      }
      if (errorMessage.contains("Username is already taken")) {
        usernameError.value = "This username is already in use.";
        errors.add(usernameError.value);
      }
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors.join("\n"));
    } else {
      _showErrorDialog(
        "Phone number is already in use or Username is already taken.",
      );
    }
  }

  bool _validateInput() {
    usernameError.value = "";
    phoneError.value = "";
    jobTitleError.value = "";
    passwordMatchError.value = "";

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final jobTitle = jobTitleController.text.trim();
    final phone = phoneController.text.trim();

    if (username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        jobTitle.isEmpty ||
        phone.isEmpty) {
      _showErrorDialog("Please fill in all fields.");
      return false;
    }

    if (password != confirmPassword) {
      passwordMatchError.value = "Passwords do not match.";
      _showErrorDialog(passwordMatchError.value);
      return false;
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(jobTitle)) {
      jobTitleError.value = "Job title must contain letters only.";
      _showErrorDialog(jobTitleError.value);
      return false;
    }

    if (!RegExp(r'^\d{11}$').hasMatch(phone)) {
      phoneError.value = "Phone number must be exactly 11 digits.";
      _showErrorDialog(phoneError.value);
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    EnhancedSnackBar.showError(title: "Registration Error", message: message);
  }
}
