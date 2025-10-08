// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
import 'package:ocl2/widgets/Avatar/user_avatar_controller.dart';
import 'package:ocl2/routes/routes.dart';

class UserAvatarWidget extends StatelessWidget {
  final double size;

  UserAvatarWidget({this.size = 45});

  final TopBarController topBarController = Get.find<TopBarController>();
  final UserAvatarController userAvatarController =
      Get.find<UserAvatarController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showUserMenu(context),
      child: Obx(() {
        String imageUrl =
            topBarController.userImageUrl.value.isNotEmpty
                ? "http://ahmedlogicpro-001-site5.qtempurl.com${topBarController.userImageUrl.value}"
                : '';

        return CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage('assets/icons/dfa.jpg') as ImageProvider,
        );
      }),
    );
  }

  void _showUserMenu(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 308,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.24),
                  blurRadius: 32,
                  offset: const Offset(4, 8),
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          topBarController.userImageUrl.value.isNotEmpty
                              ? NetworkImage(
                                "http://ahmedlogicpro-001-site5.qtempurl.com${topBarController.userImageUrl.value}",
                              )
                              : const AssetImage('assets/icons/dfa.jpg')
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            topBarController.loggedInUsername.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Obx(
                          () => Text(
                            userAvatarController.jobTitle.value,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                ),
                _buildMenuItem(
                  Icons.person_outline,
                  "My Profile",
                  () => Get.toNamed(AppRoutes.profile),
                  isDarkMode,
                ),

                _buildMenuItem(Icons.info_outline, "About Developer", () {
                  Get.toNamed(AppRoutes.info);
                }, isDarkMode),
                _buildMenuItem(Icons.logout, "Log Out", () {
                  userAvatarController.showLogoutConfirmation();
                }, isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String text,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
