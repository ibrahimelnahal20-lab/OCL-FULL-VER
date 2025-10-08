// lib/pages/login_page.dart
// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/Theme/theme_controller.dart';
import 'package:ocl2/Login%20-%20Singup/login_controller.dart';
import 'package:ocl2/widgets/TopBar/top_bar_controller.dart';
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
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
    final loginController = Get.find<LoginController>();
    final themeController = Get.find<ThemeController>();
    final topBarController = Get.find<TopBarController>();

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
            child: SingleChildScrollView(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: Column(
                  children: [
                    // Header with theme toggle
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                      color: primaryAccentColor.withOpacity(
                                        0.3,
                                      ),
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

                    // Main content
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
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
                                            "Welcome Back!",
                                            style: GoogleFonts.poppins(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Sign in to continue your journey",
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
                                          loginController.usernameController,
                                      label: "Username or ID",
                                      hint: "Enter your username or ID",
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
                                            loginController.passwordController,
                                        label: "Password",
                                        hint: "Enter your password",
                                        icon: Icons.lock_outline_rounded,
                                        isPassword: true,
                                        isPasswordVisible:
                                            loginController
                                                .isPasswordVisible
                                                .value,
                                        onTogglePassword:
                                            loginController
                                                .togglePasswordVisibility,
                                        isDark: isDark,
                                        primaryColor: primaryAccentColor,
                                        textColor: textColor,
                                        subtitleColor: subtitleColor,
                                        inputFillColor: inputFillColor,
                                        inputBorderColor: inputBorderColor,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Remember me and forgot password
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Obx(
                                          () => Row(
                                            children: [
                                              Transform.scale(
                                                scale: 0.9,
                                                child: Checkbox(
                                                  value:
                                                      loginController
                                                          .rememberMe
                                                          .value,
                                                  onChanged:
                                                      (value) => loginController
                                                          .toggleRememberMe(
                                                            value,
                                                          ),
                                                  activeColor:
                                                      primaryAccentColor,
                                                  checkColor:
                                                      isDark
                                                          ? Colors.black
                                                          : Colors.white,
                                                  side: BorderSide(
                                                    color: inputBorderColor,
                                                    width: 1.5,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "Remember me",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // TODO: Implement forgot password
                                          },
                                          child: Text(
                                            "Forgot Password?",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: primaryAccentColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),

                                    // Login button
                                    Obx(
                                      () => _buildModernButton(
                                        text:
                                            loginController.isLoading.value
                                                ? "Signing In..."
                                                : "Sign In",
                                        onPressed:
                                            loginController.isLoading.value
                                                ? null
                                                : loginController.login,
                                        isLoading:
                                            loginController.isLoading.value,
                                        isDark: isDark,
                                        primaryColor: primaryAccentColor,
                                        textColor: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Continue as guest
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          topBarController.loginAsGuest();
                                          Get.offAllNamed(AppRoutes.home);
                                        },
                                        child: Text(
                                          "Continue as Guest",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: primaryAccentColor
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Sign up link
                                    Center(
                                      child: GestureDetector(
                                        onTap:
                                            () => Get.offAllNamed(
                                              AppRoutes.signup,
                                            ),
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Don't have an account? ",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: subtitleColor,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "Sign Up",
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
                  ],
                ),
              ),
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
