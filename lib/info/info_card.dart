// lib/info/info_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
// تم إزالة: import 'package:url_launcher/url_launcher.dart';

// --- تعريفات الألوان لتحسين التصميم (تبقى كما هي) ---

// ألوان الوضع الداكن للبطاقة
const Color _dCardBgColor = Color(0xFF2D3748);
const Color _dTitleAccentColor = Color(0xFF5EEAD4);
const Color _dSectionTitleColor = Color(0xFFE5E7EB);
const Color _dTextColor = Color(0xFFD1D5DB);
const Color _dSubtleTextColor = Color(0xFF9CA3AF);
const Color _dDividerColor = Color(0xFF4B5563);
const Color _dFeatureIconColor = Color(0xFF34D399);
const Color _dShadowColor = Color(0x4A000000);

// ألوان الوضع الفاتح للبطاقة
const Color _lCardBgColor = Colors.white;
const Color _lTitleAccentColor = Color(0xFF0D9488);
const Color _lSectionTitleColor = Color(0xFF1F2937);
const Color _lTextColor = Color(0xFF374151);
const Color _lSubtleTextColor = Color(0xFF6B7280);
const Color _lDividerColor = Color(0xFFE5E7EB);
const Color _lFeatureIconColor = Color(0xFF059669);
const Color _lShadowColor = Color(0x1F000000);


class InfoCard extends StatelessWidget {
  final String appVersion;

  const InfoCard({
    super.key,
    this.appVersion = '1.0.6',
  });

  // تم إزالة دالة: _launchUniversalLink

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    final cardBgColor = isDark ? _dCardBgColor : _lCardBgColor;
    final titleAccentColor = isDark ? _dTitleAccentColor : _lTitleAccentColor;
    final sectionTitleColor = isDark ? _dSectionTitleColor : _lSectionTitleColor;
    final textColor = isDark ? _dTextColor : _lTextColor;
    final subtleTextColor = isDark ? _dSubtleTextColor : _lSubtleTextColor;
    final dividerColor = isDark ? _dDividerColor : _lDividerColor;
    final shadowColor = isDark ? _dShadowColor : _lShadowColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleAccentColor),
                      tooltip: "Back",
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Center(
                    child: Text(
                      'OCL',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: titleAccentColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Task Management System - v$appVersion',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: subtleTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildSectionTitle('📌 Project Info', sectionTitleColor),
                  const SizedBox(height: 12),
                  Text(
                    'This platform is built to help teams efficiently manage, assign, '
                        'and track tasks across projects. It supports user roles, '
                        'real-time task updates, and seamless collaboration between '
                        'editors and managers.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor,
                      height: 1.6,
                    ),
                  ),
                  Divider(height: 35, thickness: 1, color: dividerColor),

                  _buildSectionTitle('✅ Project Features', sectionTitleColor),
                  const SizedBox(height: 12),
                  ..._features.map((feature) => _buildFeatureItem(feature, isDark)),
                  Divider(height: 35, thickness: 1, color: dividerColor),

                  _buildSectionTitle('👨‍💻 Developer Info', sectionTitleColor),
                  const SizedBox(height: 12),
                  _buildDeveloperInfoItem(Icons.person_outline_rounded, 'Name: Ibrahim Ahmed', textColor),
                  _buildDeveloperInfoItem(
                    Icons.email_outlined,
                    'Email: regulardeveloper72@gmail.com',
                    textColor,
                    // تم إزالة: onTap
                  ),
                  _buildDeveloperInfoItem(
                    Icons.phone_outlined,
                    'Phone: 01273368009',
                    textColor,
                    // تم إزالة: onTap
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'I’m a passionate Flutter Developer specialized in building '
                        'scalable and user-friendly mobile & web applications using '
                        'Flutter, Dart, and GetX. I focus on clean architecture, '
                        'responsive UI, and maintainable codebases.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  final List<String> _features = const [
    "UI/UX Design",
    "API Integration (PATCH, GET, POST)",
    "Responsive Layout for Web & Mobile",
    "Theme Switching (Light & Dark)",
    "GetX State Management",
    "Error Handling with Dialogs",
    "Role-based Access (Admin/User)",
    "Real-time Task Updates",
    "Clean Architecture Pattern"
  ];

  Widget _buildFeatureItem(String feature, bool isDark) {
    final featureIconColor = isDark ? _dFeatureIconColor : _lFeatureIconColor;
    final featureTextColor = isDark ? _dTextColor : _lTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: featureIconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: featureTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تعديل ويدجت مساعد لبناء عنصر معلومات المطور (بدون تفاعلية النقر)
  Widget _buildDeveloperInfoItem(IconData icon, String text, Color color) { // تم إزالة onTap
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _lSubtleTextColor), // استخدام لون موحد وخافت للأيقونة دائماً
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: color,
              ),
            ),
          ),
          // تم إزالة أيقونة الإطلاق
        ],
      ),
    );
  }
}