// lib/routes/routes.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ocl2/Home/Home_page.dart';
import 'package:ocl2/Home/OverSub/over_sub_task.dart';
import 'package:ocl2/Login - Singup/login_page.dart';
import 'package:ocl2/Login - Singup/SignupPage.dart';
import 'package:ocl2/Team/Team_Page.dart';
import 'package:ocl2/Tasks Pages/UsersTasks/user_task_page.dart';
import 'package:ocl2/Tasks Pages/CreateTask/task_page.dart';
import 'package:ocl2/Tasks Pages/SubTasks/sub_task_page.dart';
import 'package:ocl2/Tasks Pages/User SubTask/user_sub_task_page.dart';
import 'package:ocl2/info/info_card.dart';
import 'package:ocl2/Profile/profile_popup.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:ocl2/Splash/splash_screen.dart';
import 'package:ocl2/Attendance/attendance_overview_page.dart';

class AuthGuard extends GetMiddleware {
  final TopBarController _topBar = Get.find<TopBarController>();

  @override
  RouteSettings? redirect(String? route) {
    final isGuest = _topBar.userType.value == 'guest';
    final allowedForGuest = [
      AppRoutes.login,
      AppRoutes.home,
      AppRoutes.overview,
    ];

    if (isGuest && route != null && !allowedForGuest.contains(route)) {
      return const RouteSettings(name: AppRoutes.overview);
    }
    return null;
  }
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String signup = '/signup';
  static const String team = '/team';
  static const String task = '/task';
  static const String userTask = '/UserTask';
  static const String subTask = '/subTask';
  static const String userSubTask = '/userSubTask';
  static const String info = '/info';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String overview = '/overview';
  static const String attendanceOverview = '/attendance_overview';
  static const String chat = '/chat';

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: home, page: () => HomePage(), middlewares: [AuthGuard()]),
    GetPage(name: signup, page: () => SignupPage()),
    GetPage(name: team, page: () => TeamPage(), middlewares: [AuthGuard()]),
    GetPage(name: task, page: () => TaskPage(), middlewares: [AuthGuard()]),
    GetPage(
      name: userTask,
      page: () => UserTaskPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: subTask,
      page: () => SubTaskPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: userSubTask,
      page: () => UserSubTaskPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(name: info, page: () => InfoCard()),
    GetPage(
      name: profile,
      page: () => ProfilePage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: overview,
      page: () => SubTaskOverviewPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: attendanceOverview,
      page: () => AttendanceOverviewPage(),
      middlewares: [AuthGuard()],
    ),
  ];
}
