// File: lib/screens/sub_task_page.dart

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/routes/routes.dart'; // Ensure this path is correct
import '../SubTasks/sub_task_controller.dart'; // Ensure this path is correct
import 'package:ocl2/widgets/TopBar/top_bar.dart'; // Ensure this path is correct
import 'package:ocl2/widgets/SideBar/sidebar.dart'; // Ensure this path is correct

class SubTaskPage extends StatelessWidget {
  SubTaskPage({super.key});

  final SubTaskController controller = Get.put(SubTaskController());
  final _formKey = GlobalKey<FormState>();

  // --- Dark Mode Color Definitions ---
  static const List<Color> dmGradientColors = [
    Color(0xFF0D1117),
    Color(0xFF161B22),
    Color(0xFF101A3D),
  ];
  static const Color dmCardColor = Color(0xFF161B22);
  static const Color dmSurfaceColor = Color(0xFF21262C);
  static const Color dmBorderColor = Color(0xFF30363D);
  static const Color dmTextColorPrimary = Colors.white;
  static const Color dmTextColorSecondary = Colors.white70;
  static const Color dmIconColor = Colors.white70;
  // يمكنك استخدام لون الثيم الأساسي للتركيز أو لون مميز للوضع المظلم
  static Color dmFocusColor =
      Colors.blueAccent.shade100; // تعديل طفيف للون التركيز

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark
              ? dmGradientColors[0]
              : Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Row(
            children: [
              Sidebar(isDarkMode: isDark),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        isDark
                            ? LinearGradient(
                              colors: dmGradientColors,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.3, 1.0],
                            )
                            : null,
                    color: isDark ? null : Theme.of(context).canvasColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 100, bottom: 40),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HeaderTitle(isDark: isDark),
                                const SizedBox(height: 20),
                                TopButtons(isDark: isDark), // الأزرار العلوية
                                const SizedBox(height: 30),
                                SectionCard(
                                  title: "SubTask Info",
                                  isDark: isDark,
                                  children: [
                                    Label("Name", isDark: isDark),
                                    TaskField(isDark: isDark),
                                    const SizedBox(height: 20),
                                    Label("Editor", isDark: isDark),
                                    EditorField(isDark: isDark),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SectionCard(
                                  title: "Schedule",
                                  isDark: isDark,
                                  children: [
                                    Label("Start Date", isDark: isDark),
                                    DateField(
                                      controller:
                                          controller.startDateController,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 20),
                                    Label("Deadline Date", isDark: isDark),
                                    DateField(
                                      controller: controller.deadlineController,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SectionCard(
                                  title: "Note",
                                  isDark: isDark,
                                  children: [
                                    Label("Note", isDark: isDark),
                                    NoteField(
                                      controller: controller.noteController,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        controller.createSubTask();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isDark
                                              ? dmSurfaceColor
                                              : Colors.blueAccent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: isDark ? 3 : 2,
                                    ),
                                    child: TextButtonLabel(
                                      "Create SubTask",
                                      isDark: isDark,
                                      onAccentBackgroundColor:
                                          isDark
                                              ? dmSurfaceColor
                                              : Colors.blueAccent,
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
          TopBarWidget(),
        ],
      ),
    );
  }
}

class HeaderTitle extends StatelessWidget {
  final bool isDark;
  const HeaderTitle({required this.isDark, super.key});

  @override
  Widget build(BuildContext context) => Text(
    "Create SubTask",
    style: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color:
          isDark
              ? SubTaskPage.dmTextColorPrimary
              : Theme.of(context).textTheme.bodyLarge!.color,
    ),
  );
}

class TopButtons extends StatelessWidget {
  final bool isDark;
  const TopButtons({required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    // تم تغيير لون الخلفية ليتناسق مع الثيم الداكن
    final buttonBgColor =
        isDark ? SubTaskPage.dmSurfaceColor : Colors.orange.shade700;
    final buttonTextColor =
        isDark ? SubTaskPage.dmTextColorPrimary : Colors.white;

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.overview),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBgColor,
              foregroundColor: buttonTextColor, // لون النص
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: isDark ? 3 : 2,
            ),
            child: Text(
              "Overview",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.userSubTask),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBgColor,
              foregroundColor: buttonTextColor, // لون النص
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: isDark ? 3 : 2,
            ),
            child: Text(
              "User SubTask",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;

  const SectionCard({
    required this.title,
    required this.children,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: isDark ? 3 : 2, // تعديل طفيف للـ elevation
    color: isDark ? SubTaskPage.dmCardColor : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color:
            isDark
                ? SubTaskPage.dmBorderColor.withOpacity(0.5)
                : Colors.grey.shade200, // تخفيف حدة لون الحد
        width: 0.8,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? SubTaskPage.dmTextColorPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    ),
  );
}

class Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const Label(this.text, {required this.isDark, super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        // استخدام dmTextColorSecondary للنصوص الفرعية في الوضع المظلم
        color:
            isDark
                ? SubTaskPage.dmTextColorSecondary
                : Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black54,
      ),
    ),
  );
}

class TaskField extends StatelessWidget {
  final bool isDark;
  const TaskField({required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubTaskController>();
    final fieldFillColor =
        isDark ? SubTaskPage.dmSurfaceColor : Colors.grey[100]!;
    final textColor = isDark ? SubTaskPage.dmTextColorPrimary : Colors.black87;
    final hintColor =
        isDark ? SubTaskPage.dmTextColorSecondary : Colors.grey.shade600;
    final borderColor =
        isDark
            ? SubTaskPage.dmBorderColor
            : Colors.grey.shade300; // لون أفتح قليلاً للحد في الوضع الفاتح
    final focusColor =
        isDark ? SubTaskPage.dmFocusColor : Theme.of(context).primaryColor;
    final dialogBgColor = isDark ? SubTaskPage.dmCardColor : Colors.white;
    final dialogTextColor =
        isDark ? SubTaskPage.dmTextColorPrimary : Colors.black87;
    final dialogSurfaceColor =
        isDark ? SubTaskPage.dmSurfaceColor : Colors.grey.shade100;

    String search = '';

    return TextFormField(
      controller: controller.nameController,
      readOnly: true,
      style: GoogleFonts.poppins(fontSize: 14, color: textColor),
      decoration: InputDecoration(
        hintText: 'Choose Name',
        hintStyle: GoogleFonts.poppins(color: hintColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusColor, width: 1.5),
        ),
        filled: true,
        fillColor: fieldFillColor,
        suffixIcon: Icon(
          Icons.search,
          color: isDark ? SubTaskPage.dmIconColor : Colors.grey.shade700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
      onTap:
          () => showDialog(
            context: context,
            builder:
                (_) => StatefulBuilder(
                  builder: (_, setSt) {
                    final filtered =
                        controller.availableTasks
                            .where(
                              (t) => t.toLowerCase().contains(
                                search.toLowerCase(),
                              ),
                            )
                            .toList();
                    return AlertDialog(
                      backgroundColor: dialogBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              isDark
                                  ? SubTaskPage.dmBorderColor
                                  : Colors.transparent,
                        ),
                      ),
                      title: Text(
                        'Select Task',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: dialogTextColor,
                        ),
                      ),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 400,
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (v) => setSt(() => search = v),
                              style: GoogleFonts.poppins(
                                color: dialogTextColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: GoogleFonts.poppins(
                                  color: dialogTextColor.withOpacity(0.7),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        isDark
                                            ? SubTaskPage.dmBorderColor
                                            : Colors.grey.shade400,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        isDark
                                            ? SubTaskPage.dmFocusColor
                                            : Theme.of(context).primaryColor,
                                  ),
                                ),
                                filled: true,
                                fillColor: dialogSurfaceColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder:
                                    (_, i) => ListTile(
                                      title: Text(
                                        filtered[i],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: dialogTextColor,
                                        ),
                                      ),
                                      onTap: () {
                                        controller.nameController.text =
                                            filtered[i];
                                        Get.back();
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      hoverColor:
                                          isDark
                                              ? SubTaskPage.dmSurfaceColor
                                                  .withOpacity(0.7)
                                              : Colors.grey.shade200,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
    );
  }
}

class EditorField extends StatelessWidget {
  final bool isDark;
  const EditorField({required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubTaskController>();
    final fieldFillColor =
        isDark ? SubTaskPage.dmSurfaceColor : Colors.grey[100]!;
    final textColor = isDark ? SubTaskPage.dmTextColorPrimary : Colors.black87;
    final hintColor =
        isDark ? SubTaskPage.dmTextColorSecondary : Colors.grey.shade600;
    final borderColor =
        isDark ? SubTaskPage.dmBorderColor : Colors.grey.shade300;
    final focusColor =
        isDark ? SubTaskPage.dmFocusColor : Theme.of(context).primaryColor;
    final dropdownMenuColor =
        isDark
            ? SubTaskPage.dmCardColor
            : Colors.white; // استخدام dmCardColor لقائمة منسدلة أغمق

    return Obx(
      () => DropdownButtonFormField<String>(
        value:
            controller.selectedEditor.value == ""
                ? null
                : controller.selectedEditor.value,
        decoration: InputDecoration(
          hintText: 'Choose Editor',
          hintStyle: GoogleFonts.poppins(color: hintColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 0.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: focusColor, width: 1.5),
          ),
          filled: true,
          fillColor: fieldFillColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 14, color: textColor),
        dropdownColor: dropdownMenuColor,
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? SubTaskPage.dmIconColor : Colors.grey.shade700,
        ),
        items:
            controller.availableManagers
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(
                      m,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textColor,
                      ), // لون النص داخل القائمة
                    ),
                  ),
                )
                .toList(),
        onChanged: (v) {
          if (v != null) {
            controller.selectedEditor.value = v;
            controller.editorController.text = v;
          }
        },
        validator: (v) => v == null || v.isEmpty ? "Editor is required" : null,
      ),
    );
  }
}

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const DateField({required this.controller, required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    final fieldFillColor =
        isDark ? SubTaskPage.dmSurfaceColor : Colors.grey[100]!;
    final textColor = isDark ? SubTaskPage.dmTextColorPrimary : Colors.black87;
    final hintColor =
        isDark ? SubTaskPage.dmTextColorSecondary : Colors.grey.shade600;
    final borderColor =
        isDark ? SubTaskPage.dmBorderColor : Colors.grey.shade300;
    final focusColor =
        isDark ? SubTaskPage.dmFocusColor : Theme.of(context).primaryColor;
    final iconColor = isDark ? SubTaskPage.dmIconColor : Colors.grey.shade700;

    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(fontSize: 14, color: textColor),
      validator:
          (v) => v == null || v.trim().isEmpty ? "Date is required" : null,
      decoration: InputDecoration(
        hintText: "Select Date",
        hintStyle: GoogleFonts.poppins(color: hintColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusColor, width: 1.5),
        ),
        filled: true,
        fillColor: fieldFillColor,
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, color: iconColor),
          onPressed: () {
            // تأكد من أن دالة pickDate في الكنترولر تتعامل مع isDark لتطبيق الثيم على DatePicker
            Get.find<SubTaskController>().pickDate(context, controller, isDark);
          },
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
      ),
    );
  }
}

class NoteField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const NoteField({required this.controller, required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    final fieldFillColor =
        isDark ? SubTaskPage.dmSurfaceColor : Colors.grey[100]!;
    final textColor = isDark ? SubTaskPage.dmTextColorPrimary : Colors.black87;
    final borderColor =
        isDark ? SubTaskPage.dmBorderColor : Colors.grey.shade300;
    final focusColor =
        isDark ? SubTaskPage.dmFocusColor : Theme.of(context).primaryColor;
    final hintColor =
        isDark ? SubTaskPage.dmTextColorSecondary : Colors.grey.shade600;

    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14, color: textColor),
      minLines: 4,
      maxLines: 6,
      decoration: InputDecoration(
        hintText: "Enter any notes here...",
        hintStyle: GoogleFonts.poppins(color: hintColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusColor, width: 1.5),
        ),
        filled: true,
        fillColor: fieldFillColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
      ),
    );
  }
}

class TextButtonLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  final Color? onAccentBackgroundColor; // لون خلفية الزر إذا كان مميزًا

  const TextButtonLabel(
    this.text, {
    this.isDark = false,
    this.onAccentBackgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool useWhiteText = false;
    if (onAccentBackgroundColor != null) {
      // إذا كانت الخلفية داكنة جدًا أو لون مميز ساطع، استخدم نص أبيض
      // هذا تقدير بسيط، يمكن تحسينه بناءً على قيمة السطوع الفعلية للون
      if (onAccentBackgroundColor == SubTaskPage.dmSurfaceColor ||
          onAccentBackgroundColor == Colors.blueAccent ||
          onAccentBackgroundColor == Colors.orange.shade700) {
        useWhiteText = true;
      }
    } else {
      useWhiteText = isDark;
    }

    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color:
            useWhiteText
                ? Colors.white
                : (isDark
                    ? SubTaskPage.dmTextColorPrimary
                    : Colors.white), // يظل أبيض بشكل عام للأزرار
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
