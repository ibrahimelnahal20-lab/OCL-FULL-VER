// lib/bindings/initial_binding.dart

import 'package:get/get.dart';
import 'package:ocl2/Login - Singup/login_controller.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:ocl2/Theme/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController(), permanent: true);
    Get.put(TopBarController(), permanent: true);
    Get.put(ThemeController(), permanent: true);
  }
}
