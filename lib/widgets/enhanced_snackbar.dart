import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EnhancedSnackBar {
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      shouldIconPulse: false,
      barBlur: 10,
      overlayBlur: 0.5,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }

  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.error_outline_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      shouldIconPulse: false,
      barBlur: 10,
      overlayBlur: 0.5,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }

  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFF59E0B),
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      shouldIconPulse: false,
      barBlur: 10,
      overlayBlur: 0.5,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }

  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF3B82F6),
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      shouldIconPulse: false,
      barBlur: 10,
      overlayBlur: 0.5,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }
}

class EnhancedDialog {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E2E)
                      : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    color: const Color(0xFF4F46E5),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (cancelText != null)
                      Expanded(
                        child: Container(
                          height: 48,
                          margin: const EdgeInsets.only(right: 8),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onCancel?.call();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: const Color(0xFF4F46E5).withOpacity(0.3),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              cancelText,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (confirmText != null)
                      Expanded(
                        child: Container(
                          height: 48,
                          margin: const EdgeInsets.only(left: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onConfirm?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              confirmText,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
