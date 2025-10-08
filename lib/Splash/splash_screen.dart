// lib/widgets/Splash/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:ocl2/Theme/theme_controller.dart';
import 'package:ocl2/routes/routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // سجل الـ controller للتحكّم بالانتقال
    Get.put(_SplashController());

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final bool isDark = themeCtrl.isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
          body: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Lottie.asset('assets/lottie/logo.json'),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // بعد 10 ثواني انتقل للصفحة المحفوظة أو صفحة الدخول
    final box = GetStorage();
    Timer(const Duration(seconds: 3), () {
      final next = box.read<String>('lastPage') ?? AppRoutes.login;
      Get.offNamed(next);
    });
  }
}
