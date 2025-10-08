// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ocl2/API/API.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';

class TeamController extends GetxController {
  var isLoading = true.obs;
  var teamMembers = <Map<String, dynamic>>[].obs;
  final TopBarController topBarController = Get.find();

  @override
  void onInit() {
    super.onInit();
    fetchTeamMembers();
  }

  Future<void> fetchTeamMembers() async {
    try {
      isLoading(true);

      // ✅ جلب بيانات المستخدمين
      final userResponse = await API.getData(EndPoints.users);
      // ✅ جلب بيانات المهام
      final taskResponse = await API.getData(EndPoints.task);

      if (userResponse.statusCode == 200 &&
          userResponse.data is List &&
          taskResponse.statusCode == 200 &&
          taskResponse.data is List) {
        String currentUser = topBarController.loggedInUsername.value;

        // ✅ تحويل بيانات المستخدمين إلى Map
        Map<String, Map<String, dynamic>> usersMap = {
          for (var user in userResponse.data)
            user["username"]: {
              "username": user["username"]?.toString() ?? "",
              "jobTitle": user["jobTitle"]?.toString() ?? "",
              "imageUrl": user["imageUrl"]?.toString() ?? "",
              "description": user["description"]?.toString() ?? "",
              "userType": user["userType"]?.toString() ?? "",
              "allTasks": 0, // ✅ عدد جميع المهام
              "completedTasks": 0, // ✅ عدد المهام المكتملة
            },
        };

        // ✅ حساب المهام لكل مستخدم
        for (var task in taskResponse.data) {
          String projectManagers = task["projectManager"]?.toString() ?? "";
          String taskStatus = task["taskStatus"]?.toString() ?? "";

          if (projectManagers.isNotEmpty) {
            List<String> managers =
                projectManagers.split(" - ").map((e) => e.trim()).toList();

            for (var manager in managers) {
              if (usersMap.containsKey(manager)) {
                usersMap[manager]!["allTasks"] += 1;
                if (taskStatus == "Complete") {
                  usersMap[manager]!["completedTasks"] += 1;
                }
              }
            }
          }
        }

        // ✅ تحويل Map إلى List وإضافته إلى `teamMembers`
        teamMembers.value = usersMap.values.toList();

        // ✅ ترتيب المستخدمين بنفس الطريقة السابقة
        teamMembers.sort((a, b) {
          if (a["username"] == currentUser) {
            return -1;
          } else if (b["username"] == currentUser) {
            return 1;
          } else if (a["userType"] == "admin" && b["userType"] != "admin") {
            return -1;
          } else if (a["userType"] != "admin" && b["userType"] == "admin") {
            return 1;
          }
          return 0;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching team members: $e");
      }
    } finally {
      isLoading(false);
    }
  }
}
