// lib/pages/signup_page.dart
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/Login - Singup/signup_controller.dart';
import 'package:ocl2/Theme/theme_controller.dart';
import 'package:ocl2/widgets/password_strength_indicator.dart';
import '../routes/routes.dart';

// Enhanced Modern Color Palette
const List<Color> _kDarkGradientBackground = [
  Color(0xFF0A0A0A),
  Color(0xFF1A1A2E),
  Color(0xFF16213E),
  Color(0xFF0F3460),
];

const List<Color> _kLightGradientBackground = [
  Color(0xFFF8FAFC), // Light gray
  Color(0xFFF1F5F9), // Lighter gray
];

const Color _kDarkCardBgColor = Color(0xFF1E1E2E);
const Color _kLightCardBgColor = Color(0xFFFFFFFF);
const Color _kDarkPrimaryAccent = Color(0xFF00D4FF);
const Color _kLightPrimaryAccent = Color(0xFF3B82F6);

const double kSmallVerticalSpace = 12.0;
const double kMediumVerticalSpace = 24.0;
const double kLargeVerticalSpace = 36.0;
const double kExtraLargeVerticalSpace = 48.0;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupController = Get.put(SignupController());
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final ThemeMode currentMode = themeController.currentThemeMode.value;
      bool isDark;
      if (currentMode == ThemeMode.system) {
        isDark = Get.isDarkMode;
      } else {
        isDark = (currentMode == ThemeMode.dark);
      }

      final List<Color> bodyGradientColors =
          isDark ? _kDarkGradientBackground : _kLightGradientBackground;
      final Color cardBgColor = isDark ? _kDarkCardBgColor : _kLightCardBgColor;
      final Color primaryAccentColor =
          isDark ? _kDarkPrimaryAccent : _kLightPrimaryAccent;
      final Color textColor = isDark ? Colors.white : Colors.grey[800]!;
      final Color subtitleColor = isDark ? Colors.white70 : Colors.grey[600]!;
      final Color inputFillColor =
          isDark ? const Color(0xFF2A2A3E) : Colors.grey[50]!;
      final Color inputBorderColor =
          isDark ? Colors.grey[600]! : Colors.grey[300]!;

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bodyGradientColors,
              stops:
                  bodyGradientColors.length == 4
                      ? const [0.0, 0.33, 0.66, 1.0]
                      : const [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with back button and theme toggle
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBgColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: cardBgColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: primaryAccentColor,
                              size: 20,
                            ),
                            onPressed: () => Get.offAllNamed(AppRoutes.login),
                            tooltip: 'Go back to Login',
                          ),
                        ),
                      ),
                      // Enhanced Logo/Brand
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryAccentColor.withOpacity(0.15),
                                primaryAccentColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: primaryAccentColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryAccentColor.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "OCL",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: primaryAccentColor,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(
                                  color: primaryAccentColor.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Theme toggle
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBgColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: cardBgColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              color: primaryAccentColor,
                            ),
                            onPressed: themeController.toggleTheme,
                            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content - Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Welcome text
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          "Create Account",
                                          style: GoogleFonts.poppins(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Join us and start your journey!",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: subtitleColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  // Username field
                                  _buildModernTextField(
                                    controller:
                                        signupController.usernameController,
                                    label: "Username",
                                    hint: "Enter your username",
                                    icon: Icons.person_outline_rounded,
                                    isDark: isDark,
                                    primaryColor: primaryAccentColor,
                                    textColor: textColor,
                                    subtitleColor: subtitleColor,
                                    inputFillColor: inputFillColor,
                                    inputBorderColor: inputBorderColor,
                                  ),
                                  const SizedBox(height: 24),

                                  // Password field
                                  Obx(
                                    () => _buildModernTextField(
                                      controller:
                                          signupController.passwordController,
                                      label: "Password",
                                      hint: "Enter your password",
                                      icon: Icons.lock_outline_rounded,
                                      isPassword: true,
                                      isPasswordVisible:
                                          signupController
                                              .isPasswordVisible
                                              .value,
                                      onTogglePassword:
                                          signupController
                                              .togglePasswordVisibility,
                                      isDark: isDark,
                                      primaryColor: primaryAccentColor,
                                      textColor: textColor,
                                      subtitleColor: subtitleColor,
                                      inputFillColor: inputFillColor,
                                      inputBorderColor: inputBorderColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Password strength indicator
                                  Obx(
                                    () => PasswordStrengthIndicator(
                                      password:
                                          signupController.passwordText.value,
                                      isDarkMode: isDark,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Confirm Password field
                                  Obx(
                                    () => _buildModernTextField(
                                      controller:
                                          signupController
                                              .confirmPasswordController,
                                      label: "Confirm Password",
                                      hint: "Re-enter your password",
                                      icon: Icons.lock_outline_rounded,
                                      isPassword: true,
                                      isPasswordVisible:
                                          signupController
                                              .isConfirmPasswordVisible
                                              .value,
                                      onTogglePassword:
                                          signupController
                                              .toggleConfirmPasswordVisibility,
                                      isDark: isDark,
                                      primaryColor: primaryAccentColor,
                                      textColor: textColor,
                                      subtitleColor: subtitleColor,
                                      inputFillColor: inputFillColor,
                                      inputBorderColor: inputBorderColor,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Job Title field
                                  _buildModernTextField(
                                    controller:
                                        signupController.jobTitleController,
                                    label: "Job Title",
                                    hint: "Enter your job title",
                                    icon: Icons.work_outline_rounded,
                                    isDark: isDark,
                                    primaryColor: primaryAccentColor,
                                    textColor: textColor,
                                    subtitleColor: subtitleColor,
                                    inputFillColor: inputFillColor,
                                    inputBorderColor: inputBorderColor,
                                  ),
                                  const SizedBox(height: 24),

                                  // Phone field
                                  _buildModernTextField(
                                    controller:
                                        signupController.phoneController,
                                    label: "Phone",
                                    hint: "Enter your phone number",
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    isDark: isDark,
                                    primaryColor: primaryAccentColor,
                                    textColor: textColor,
                                    subtitleColor: subtitleColor,
                                    inputFillColor: inputFillColor,
                                    inputBorderColor: inputBorderColor,
                                  ),
                                  const SizedBox(height: 40),

                                  // Sign up button
                                  Obx(
                                    () => _buildModernButton(
                                      text:
                                          signupController.isLoading.value
                                              ? "Creating Account..."
                                              : "Create Account",
                                      onPressed:
                                          signupController.isLoading.value
                                              ? null
                                              : signupController.signup,
                                      isLoading:
                                          signupController.isLoading.value,
                                      isDark: isDark,
                                      primaryColor: primaryAccentColor,
                                      textColor: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Login link
                                  Center(
                                    child: GestureDetector(
                                      onTap:
                                          () =>
                                              Get.offAllNamed(AppRoutes.login),
                                      child: RichText(
                                        text: TextSpan(
                                          text: "Already have an account? ",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: subtitleColor,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "Sign In",
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: primaryAccentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
    required Color primaryColor,
    required Color textColor,
    required Color subtitleColor,
    required Color inputFillColor,
    required Color inputBorderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? !isPasswordVisible : false,
            keyboardType: keyboardType,
            onChanged: (value) {
              if (label == "Password") {
                Get.find<SignupController>().updatePasswordText(value);
              }
            },
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: subtitleColor,
              ),
              filled: true,
              fillColor: inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: inputBorderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: primaryColor.withOpacity(0.7),
                        ),
                        onPressed: onTogglePassword,
                      )
                      : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
    required bool isDark,
    required Color primaryColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.black : Colors.white,
                    ),
                  ),
                )
                : Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
