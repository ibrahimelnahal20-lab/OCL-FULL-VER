// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:ocl2/API/API.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:ocl2/routes/routes.dart';
import 'package:ocl2/Home/home_controller.dart';
import 'package:ocl2/Theme/theme_controller.dart';
import 'package:ocl2/widgets/Avatar/user_avatar_controller.dart';
import 'package:ocl2/initial_binding.dart'; // <-- هذا هو السطر الناقص

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  setPathUrlStrategy();

  // تسجيل الـ Controllers
  // يتم وضع ThemeController أولاً لضمان أن onInit الخاصة به تُستدعى مبكراً
  // ويمكنها تحميل الثيم المحفوظ قبل بناء GetMaterialApp إذا لزم الأمر.
  Get.put(ThemeController());
  Get.put(TopBarController(), permanent: true);
  Get.put(HomeController());
  Get.put(UserAvatarController());
  API.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String? testInitialRoute;
  const MyApp({super.key, this.testInitialRoute});

  @override
  Widget build(BuildContext context) {
    // لا نزال نستخدم GetBuilder للوصول إلى themeController من أجل theme و darkTheme
    // ولكن themeMode سيتم تعيينه بشكل مختلف قليلاً.
    return GetBuilder<ThemeController>(
      // لا حاجة لـ init هنا لأن ThemeController تم عمل Get.put له في main()
      builder: (themeCtl) {
        // تم تغيير اسم المتغير إلى themeCtl للوضوح
        // القيمة isDark التي كنت تستخدمها سابقاً لـ themeMode
        // ستظل مفيدة داخل الصفحات لتحديد الألوان بناءً على الثيم الحالي الفعلي.
        // أما بالنسبة لـ GetMaterialApp.themeMode، فسنحدد القيمة الافتراضية.

        final initial = testInitialRoute ?? AppRoutes.splash;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          // يفترض أن ThemeController يحتوي على getters باسم lightTheme و darkTheme
          // تُرجع كائنات ThemeData.
          theme: themeCtl.lightTheme,
          darkTheme: themeCtl.darkTheme,

          // ****** التعديل الرئيسي هنا ******
          // تعيين الوضع الداكن كوضع افتراضي أولي.
          // سيقوم ThemeController في onInit() بتطبيق أي وضع محفوظ (light أو dark)
          // إذا وجد، مما سيقوم بتجاوز هذه القيمة الأولية.
          // إذا لم يتم العثور على وضع محفوظ (أول تشغيل)، سيبقى الوضع الداكن.
          themeMode: ThemeMode.dark,
          initialBinding: InitialBinding(),
          initialRoute: initial,
          getPages: AppRoutes.pages,
        );
      },
    );
  }
}
