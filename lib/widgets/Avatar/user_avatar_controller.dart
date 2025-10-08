import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ocl2/API/api.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/routes/routes.dart';

class UserAvatarController extends GetxController {
  final TopBarController topBarController = Get.find<TopBarController>();

  static const String baseUrl = "http://ahmedlogicpro-001-site5.qtempurl.com";

  RxString userImageUrl = "".obs;
  RxString jobTitle = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserJobTitle();
  }

  Future<void> fetchUserJobTitle() async {
    if (topBarController.loggedInUsername.value.isEmpty) return;
    try {
      final response = await API.getData(
        "${EndPoints.users}?username=${topBarController.loggedInUsername.value}",
      );
      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        jobTitle.value = response.data[0]['jobTitle'] ?? "";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching job title: $e");
      }
    }
  }

  void showLogoutConfirmation() {
    bool isDarkMode = Get.isDarkMode;
    Get.defaultDialog(
      title: "Logout Confirmation",
      titleStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      barrierDismissible: false,
      radius: 12,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDarkMode ? Colors.yellowAccent : Colors.orange,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            "Are you sure you want to log out?",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDarkMode ? Colors.redAccent.shade400 : Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Get.offAllNamed(AppRoutes.login);
                },
                child: Text(
                  "Confirm",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
