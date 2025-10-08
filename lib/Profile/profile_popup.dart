// lib/screens/profile_page.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Profile/profile_controller.dart';
import '../widgets/password_strength_indicator.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => controller.goBackToHome(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [
                        const Color(0xFF0F0F23),
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                        const Color(0xFF0F3460),
                      ]
                      : [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                        const Color(0xFFf093fb),
                        const Color(0xFFf5576c),
                      ],
              stops: const [0.0, 0.25, 0.75, 1.0],
            ),
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? const Color(0xFF6A88FF)
                                : const Color(0xFF667eea),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Loading Profile...",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  width: 700,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header with gradient background
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  isDark
                                      ? [
                                        const Color(0xFF6A88FF),
                                        const Color(0xFF4A6FDC),
                                      ]
                                      : [
                                        const Color(0xFF667eea),
                                        const Color(0xFF764ba2),
                                      ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Profile Image Section
                              GestureDetector(
                                onTap: controller.pickImage,
                                child: Stack(
                                  children: [
                                    Obx(() {
                                      final Uint8List? bytes =
                                          controller.selectedImageBytes.value;
                                      final ImageProvider avatarImageProvider =
                                          bytes != null
                                              ? MemoryImage(bytes)
                                              : controller
                                                  .imageUrl
                                                  .value
                                                  .isNotEmpty
                                              ? NetworkImage(
                                                "http://ahmedlogicpro-001-site5.qtempurl.com${controller.imageUrl.value}",
                                              )
                                              : const AssetImage(
                                                'assets/icons/dfa.jpg',
                                              );

                                      return Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 4,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 58,
                                          backgroundColor:
                                              isDark
                                                  ? Colors.grey[700]
                                                  : Colors.grey[200],
                                          backgroundImage: avatarImageProvider,
                                          onBackgroundImageError:
                                              (exception, stackTrace) {},
                                          child:
                                              bytes == null &&
                                                      controller
                                                          .imageUrl
                                                          .value
                                                          .isEmpty
                                                  ? Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color:
                                                        isDark
                                                            ? Colors.grey[500]
                                                            : Colors.grey[400],
                                                  )
                                                  : null,
                                        ),
                                      );
                                    }),
                                    // Camera icon overlay
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 20,
                                          color:
                                              isDark
                                                  ? const Color(0xFF6A88FF)
                                                  : const Color(0xFF667eea),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Profile Settings",
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Manage your account information",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Content
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              // User Type Badge
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        isDark
                                            ? [
                                              const Color(0xFF4A6FDC),
                                              const Color(0xFF6A88FF),
                                            ]
                                            : [
                                              const Color(0xFFf093fb),
                                              const Color(0xFFf5576c),
                                            ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.verified_user,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "User Type: ${controller.userType.value}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Profile Information Section
                              _buildSectionHeader(
                                "Profile Information",
                                Icons.person,
                                isDark,
                              ),
                              const SizedBox(height: 20),

                              // Form Fields in Grid Layout
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildModernField(
                                          "Username",
                                          controller.usernameController,
                                          Icons.person_outline,
                                          isDark
                                              ? const Color(0xFF6A88FF)
                                              : Colors.blue,
                                          isDark: isDark,
                                        ),
                                        const SizedBox(height: 20),
                                        _buildModernField(
                                          "Job Title",
                                          controller.jobTitleController,
                                          Icons.work_outline,
                                          isDark
                                              ? const Color(0xFF4CAF50)
                                              : Colors.green,
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Right Column
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildModernField(
                                          "Phone",
                                          controller.phoneController,
                                          Icons.phone_outlined,
                                          isDark
                                              ? const Color(0xFF9C27B0)
                                              : Colors.purple,
                                          isDark: isDark,
                                          keyboardType: TextInputType.phone,
                                        ),
                                        const SizedBox(height: 20),
                                        _buildModernField(
                                          "Description",
                                          controller.descriptionController,
                                          Icons.description_outlined,
                                          isDark
                                              ? const Color(0xFF00BCD4)
                                              : Colors.teal,
                                          isDark: isDark,
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // Password Change Section
                              _buildSectionHeader(
                                "Change Password",
                                Icons.lock,
                                isDark,
                              ),
                              const SizedBox(height: 20),

                              // Password Fields
                              _buildModernField(
                                "Current Password",
                                controller.currentPasswordController,
                                Icons.lock_outline,
                                isDark
                                    ? const Color(0xFFFF9800)
                                    : Colors.orange,
                                isDark: isDark,
                                obscure: true,
                              ),
                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildModernField(
                                      "New Password",
                                      controller.newPasswordController,
                                      Icons.lock_outline,
                                      isDark
                                          ? const Color(0xFF4CAF50)
                                          : Colors.green,
                                      isDark: isDark,
                                      obscure: true,
                                      onChanged: (value) {
                                        controller.updateNewPasswordText(value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildModernField(
                                      "Confirm New Password",
                                      controller.confirmPasswordController,
                                      Icons.lock_outline,
                                      isDark
                                          ? const Color(0xFF4CAF50)
                                          : Colors.green,
                                      isDark: isDark,
                                      obscure: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Obx(
                                () => PasswordStrengthIndicator(
                                  password: controller.newPasswordText.value,
                                  isDarkMode: isDark,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Change Password Button
                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  child: _buildModernButton(
                                    controller.isChangingPassword.value
                                        ? "Changing Password..."
                                        : "Change Password",
                                    controller.isChangingPassword.value
                                        ? Icons.hourglass_empty
                                        : Icons.lock_reset,
                                    isDark
                                        ? const Color(0xFF4CAF50)
                                        : Colors.green,
                                    Colors.white,
                                    controller.isChangingPassword.value
                                        ? () {}
                                        : controller.changePassword,
                                    isDark: isDark,
                                    isPrimary: true,
                                    isLoading:
                                        controller.isChangingPassword.value,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildModernButton(
                                      "Back to Home",
                                      Icons.home,
                                      isDark
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!,
                                      isDark
                                          ? Colors.white70
                                          : Colors.grey[700]!,
                                      controller.goBackToHome,
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Obx(
                                      () => _buildModernButton(
                                        controller.isSavingProfile.value
                                            ? "Saving..."
                                            : "Save Profile",
                                        controller.isSavingProfile.value
                                            ? Icons.hourglass_empty
                                            : Icons.save_outlined,
                                        isDark
                                            ? const Color(0xFF6A88FF)
                                            : const Color(0xFF667eea),
                                        Colors.white,
                                        controller.isSavingProfile.value
                                            ? () {}
                                            : controller.saveProfileChanges,
                                        isDark: isDark,
                                        isPrimary: true,
                                        isLoading:
                                            controller.isSavingProfile.value,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? const Color(0xFF6A88FF) : const Color(0xFF667eea),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernField(
    String label,
    TextEditingController controller,
    IconData icon,
    Color iconColor, {
    bool obscure = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.grey[800],
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: iconColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildModernButton(
    String text,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed, {
    bool isPrimary = false,
    required bool isDark,
    bool isLoading = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isPrimary && !isLoading
                ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ]
                : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isLoading ? backgroundColor.withOpacity(0.6) : backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            else
              Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
