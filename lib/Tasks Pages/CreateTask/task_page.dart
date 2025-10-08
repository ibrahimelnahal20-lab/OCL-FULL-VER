// lib/Tasks Pages/CreateTask/task_page.dart
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/Tasks%20Pages/CreateTask/task_controller.dart'; // Corrected import path based on error
import 'package:ocl2/routes/routes.dart';
import 'package:ocl2/widgets/SideBar/sidebar.dart';
import 'package:ocl2/widgets/TopBar/top_bar.dart';
import 'package:ocl2/Theme/theme_controller.dart';

class TaskPage extends StatelessWidget {
  TaskPage({super.key});

  final TaskController taskController = Get.put(TaskController());
  final ThemeController themeController = Get.find<ThemeController>();
  final _formKey = GlobalKey<FormState>();

  // Dark theme specific color constants (can be kept if you prefer this override)
  static const List<Color> _kDarkGradientBackground = [
    Color(0xFF0D1117),
    Color(0xFF161B22),
    Color(0xFF101A3D),
  ];
  static const Color _kDarkCardBgColor = Color(0xFF1A202C);
  static const Color _kDarkFieldFillColor = Color(0xFF222B38);
  static const Color _kDarkBorderColorForCard = Color(0xFF2D3748);
  static const Color _kDarkInputFieldBorderColor = Color(0xFF354152);
  // Add other dark-specific constants if needed, e.g., for text
  static const Color _kDarkTextColor = Color(0xFFD1D5DB);
  static const Color _kDarkHintTextColor = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    // This is the Obx widget around line 34 causing the error
    return Obx(() {
      // 1. Directly observe the primary reactive variable from ThemeController
      final ThemeMode currentMode = themeController.currentThemeMode.value;

      // 2. Determine isDark based on the observed currentMode
      bool isDark;
      if (currentMode == ThemeMode.system) {
        // When system, rely on GetX's global dark mode status,
        // which is updated when Get.changeThemeMode(ThemeMode.system) is called.
        isDark = Get.isDarkMode;
      } else {
        isDark = (currentMode == ThemeMode.dark);
      }

      // 3. Get the active ThemeData object (this is correctly applied by GetMaterialApp)
      final ThemeData currentTheme = Theme.of(
        context,
      ); // This will be lightTheme or darkTheme from your ThemeController
      final ColorScheme colorScheme = currentTheme.colorScheme;
      final TextTheme textTheme = currentTheme.textTheme;

      // 4. Define colors based on isDark and the currentTheme
      Color cardBackgroundColor =
          isDark ? _kDarkCardBgColor : currentTheme.cardColor;
      Color borderColorForCard =
          isDark ? _kDarkBorderColorForCard : Colors.grey.shade300;
      Color fieldFillColor =
          isDark
              ? _kDarkFieldFillColor
              : (currentTheme.inputDecorationTheme.fillColor ??
                  Colors.grey[100]!);

      Color textColor =
          isDark
              ? _kDarkTextColor
              : (textTheme.bodyLarge?.color ?? colorScheme.onSurface);
      Color hintTextColor =
          isDark
              ? _kDarkHintTextColor
              : (textTheme.bodySmall?.color?.withOpacity(0.6) ??
                  colorScheme.onSurface.withOpacity(0.6));
      Color inputFieldBorderColor =
          isDark
              ? _kDarkInputFieldBorderColor
              : (currentTheme
                      .inputDecorationTheme
                      .enabledBorder
                      ?.borderSide
                      .color ??
                  Colors.grey.shade300);
      Color inputFieldFocusedBorderColor = colorScheme.primary;
      Color dropdownMenuColor =
          isDark
              ? _kDarkCardBgColor.withAlpha(240)
              : currentTheme.cardColor.withAlpha(240);

      final List<Color> bodyGradientColors =
          isDark
              ? _kDarkGradientBackground
              // Example for light gradient, adjust as needed
              : [
                currentTheme.scaffoldBackgroundColor,
                Color.lerp(
                  currentTheme.scaffoldBackgroundColor,
                  Colors.blueGrey.shade50,
                  0.5,
                )!,
              ];

      return Scaffold(
        backgroundColor:
            isDark
                ? null
                : currentTheme
                    .scaffoldBackgroundColor, // null for dark if gradient covers all
        body: SafeArea(
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Sidebar(
                    isDarkMode: isDark,
                  ), // Pass the correctly determined isDark
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient:
                            isDark
                                ? LinearGradient(
                                  colors:
                                      bodyGradientColors, // Use bodyGradientColors
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops:
                                      bodyGradientColors.length == 4
                                          ? const [0.0, 0.33, 0.66, 1.0]
                                          : bodyGradientColors.length == 3
                                          ? const [0.0, 0.5, 1.0]
                                          : const [0.0, 1.0],
                                )
                                : null,
                        color:
                            !isDark
                                ? bodyGradientColors[0]
                                : null, // Use first color of gradient or scaffold color
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          top: 100,
                          bottom: 40,
                          left: 40,
                          right: 40,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        if (Get.currentRoute !=
                                            AppRoutes.userTask) {
                                          Get.toNamed(AppRoutes.userTask);
                                        }
                                      },
                                      icon: const Icon(Icons.task_alt),
                                      label: Text(
                                        "User Task Page",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors
                                                .orange
                                                .shade700, // Specific color for this button
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    "Create New Task",
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          textTheme.headlineSmall?.color ??
                                          textColor,
                                      shadows:
                                          isDark
                                              ? [
                                                Shadow(
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ]
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(height: 35),
                                  _buildSectionCard(
                                    title: "Project Information",
                                    isDark: isDark,
                                    currentTheme: currentTheme,
                                    cardBackgroundColor: cardBackgroundColor,
                                    borderColor: borderColorForCard,
                                    children: [
                                      _buildLabel("Project Name", textColor),
                                      _buildInputField(
                                        controller:
                                            taskController
                                                .projectNameController,
                                        fieldFillColor: fieldFillColor,
                                        textColor: textColor,
                                        hintTextColor: hintTextColor,
                                        borderColor: inputFieldBorderColor,
                                        focusedBorderColor:
                                            inputFieldFocusedBorderColor,
                                        validatorText:
                                            "Project name is required",
                                        hintText: "Enter project name",
                                      ),
                                      const SizedBox(height: 20),
                                      _buildLabel(
                                        "Project Start Date",
                                        textColor,
                                      ),
                                      _buildDateField(
                                        context: context,
                                        controller:
                                            taskController.startDateController,
                                        fieldFillColor: fieldFillColor,
                                        textColor: textColor,
                                        hintTextColor: hintTextColor,
                                        borderColor: inputFieldBorderColor,
                                        focusedBorderColor:
                                            inputFieldFocusedBorderColor,
                                        hintText: "Select start date",
                                      ),
                                      const SizedBox(height: 20),
                                      _buildLabel(
                                        "Project Deadline",
                                        textColor,
                                      ),
                                      _buildDateField(
                                        context: context,
                                        controller:
                                            taskController.deadlineController,
                                        fieldFillColor: fieldFillColor,
                                        textColor: textColor,
                                        hintTextColor: hintTextColor,
                                        borderColor: inputFieldBorderColor,
                                        focusedBorderColor:
                                            inputFieldFocusedBorderColor,
                                        hintText: "Select deadline",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  _buildSectionCard(
                                    title: "Package & Extras",
                                    isDark: isDark,
                                    currentTheme: currentTheme,
                                    cardBackgroundColor: cardBackgroundColor,
                                    borderColor: borderColorForCard,
                                    children: [
                                      _buildLabel("Select Package", textColor),
                                      _buildDropdown(
                                        fieldFillColor: fieldFillColor,
                                        textColor: textColor,
                                        hintTextColor: hintTextColor,
                                        borderColor: inputFieldBorderColor,
                                        focusedBorderColor:
                                            inputFieldFocusedBorderColor,
                                        dropdownMenuColor: dropdownMenuColor,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildPackageDescription(
                                        textColor.withOpacity(0.8),
                                      ),
                                      const SizedBox(height: 25),
                                      _buildExtras(
                                        textColor: textColor,
                                        fieldFillColor: fieldFillColor,
                                        borderColor: inputFieldBorderColor,
                                        selectedColor: colorScheme.primary,
                                        isDark: isDark,
                                        currentTheme: currentTheme,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  _buildSectionCard(
                                    title: "Project Editor Assignment",
                                    isDark: isDark,
                                    currentTheme: currentTheme,
                                    cardBackgroundColor: cardBackgroundColor,
                                    borderColor: borderColorForCard,
                                    children: [
                                      _buildManagerSection(
                                        textColor: textColor,
                                        fieldFillColor: fieldFillColor,
                                        hintTextColor: hintTextColor,
                                        inputFieldBorderColor:
                                            inputFieldBorderColor,
                                        inputFieldFocusedBorderColor:
                                            inputFieldFocusedBorderColor,
                                        dropdownMenuColor: dropdownMenuColor,
                                        isDark: isDark,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          taskController.createTask();
                                        }
                                      },
                                      icon: const Icon(Icons.add_task),
                                      label: Text(
                                        "Create Task",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 5,
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
              TopBarWidget(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required bool isDark,
    required ThemeData currentTheme,
    required Color cardBackgroundColor,
    required Color borderColor,
  }) {
    return Card(
      color: cardBackgroundColor,
      elevation: isDark ? 3 : 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor.withOpacity(isDark ? 0.7 : 1.0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    currentTheme.textTheme.titleLarge?.color ??
                    (isDark ? Colors.white : Colors.black),
              ),
            ),
            Divider(
              height: 20,
              thickness: 0.5,
              color: borderColor.withOpacity(isDark ? 0.4 : 0.5),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 5),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required Color fieldFillColor,
    required Color textColor,
    required Color hintTextColor,
    required Color borderColor,
    required Color focusedBorderColor,
    String? validatorText,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14, color: textColor),
      validator: (value) {
        if (validatorText != null && (value == null || value.trim().isEmpty)) {
          return validatorText;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: hintTextColor, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
        ),
        filled: true,
        fillColor: fieldFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required Color fieldFillColor,
    required Color textColor,
    required Color hintTextColor,
    required Color borderColor,
    required Color focusedBorderColor,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(fontSize: 14, color: textColor),
      validator:
          (value) =>
              value == null || value.trim().isEmpty ? "Date is required" : null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: hintTextColor, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
        ),
        filled: true,
        fillColor: fieldFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.calendar_today_outlined,
            color: hintTextColor,
            size: 20,
          ),
          onPressed: () => taskController.pickDate(context, controller),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required Color fieldFillColor,
    required Color textColor,
    required Color hintTextColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color dropdownMenuColor,
  }) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value:
            taskController.selectedPackage.value.isEmpty
                ? null
                : taskController.selectedPackage.value,
        items:
            taskController.packageList.map((package) {
              return DropdownMenuItem<String>(
                value: package['packageName'],
                child: Text(
                  package['packageName'],
                  style: GoogleFonts.poppins(fontSize: 14, color: textColor),
                ),
              );
            }).toList(),
        onChanged: (value) => taskController.setSelectedPackage(value!),
        dropdownColor: dropdownMenuColor,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: hintTextColor,
          size: 24,
        ),
        style: GoogleFonts.poppins(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          hintText: "Select a package",
          hintStyle: GoogleFonts.poppins(color: hintTextColor, fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
          ),
          filled: true,
          fillColor: fieldFillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
        ),
        validator:
            (value) =>
                value == null || value.isEmpty ? "Package is required" : null,
      ),
    );
  }

  Widget _buildPackageDescription(Color textColor) {
    return Obx(() {
      final selected = taskController.packageList.firstWhereOrNull(
        (package) =>
            package["packageName"] == taskController.selectedPackage.value,
      );
      return selected != null
          ? Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Description: ${selected["packageDescription"]}",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: textColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
          : const SizedBox.shrink();
    });
  }

  Widget _buildExtras({
    required Color textColor,
    required Color fieldFillColor,
    required Color borderColor,
    required Color selectedColor,
    required bool isDark,
    required ThemeData currentTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Select Extras (Optional)", textColor),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                taskController.extrasOptions.map((extra) {
                  final bool isSelected = taskController.selectedExtras
                      .contains(extra);
                  return FilterChip(
                    label: Text(
                      extra,
                      style: GoogleFonts.poppins(
                        color:
                            isSelected
                                ? currentTheme.colorScheme.onPrimary
                                : textColor,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) => taskController.toggleExtra(extra),
                    selectedColor:
                        selectedColor, // This is currentTheme.colorScheme.primary
                    backgroundColor: fieldFillColor.withOpacity(
                      isDark ? 0.4 : 0.7,
                    ),
                    checkmarkColor: currentTheme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color:
                            isSelected
                                ? selectedColor.withOpacity(0.7)
                                : borderColor,
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildManagerSection({
    required Color textColor,
    required Color fieldFillColor,
    required Color hintTextColor,
    required Color inputFieldBorderColor,
    required Color inputFieldFocusedBorderColor,
    required Color dropdownMenuColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Assign Editor", textColor),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            value:
                taskController.selectedManagers.isNotEmpty
                    ? (taskController.availableManagers.contains(
                          taskController.selectedManagers.lastWhere(
                            (m) => m != "Assign later",
                            orElse: () => '',
                          ),
                        )
                        ? taskController.selectedManagers.lastWhere(
                          (m) => m != "Assign later",
                          orElse: () => '',
                        )
                        : null)
                    : null,
            items:
                taskController.selectedManagers.length < 2 ||
                        (taskController.selectedManagers.length == 1 &&
                            taskController.selectedManagers.contains(
                              "Assign later",
                            ))
                    ? taskController.availableManagers.map((String manager) {
                      return DropdownMenuItem<String>(
                        value: manager,
                        child: Text(
                          manager,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      );
                    }).toList()
                    : [],
            onChanged:
                (taskController.selectedManagers.length < 2 ||
                        (taskController.selectedManagers.length == 1 &&
                            taskController.selectedManagers.contains(
                              "Assign later",
                            )))
                    ? (value) {
                      if (value != null) {
                        taskController.addManager(value);
                      }
                    }
                    : null,
            dropdownColor: dropdownMenuColor,
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: hintTextColor,
              size: 24,
            ),
            style: GoogleFonts.poppins(fontSize: 14, color: textColor),
            decoration: InputDecoration(
              hintText:
                  (taskController.selectedManagers.length < 2 ||
                          (taskController.selectedManagers.length == 1 &&
                              taskController.selectedManagers.contains(
                                "Assign later",
                              )))
                      ? "Choose Editor"
                      : "Max 2 editors",
              hintStyle: GoogleFonts.poppins(
                color: hintTextColor,
                fontSize: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: inputFieldBorderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: inputFieldFocusedBorderColor,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
              ),
              filled: true,
              fillColor: fieldFillColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
            ),
            disabledHint:
                taskController.selectedManagers.length >= 2 &&
                        !(taskController.selectedManagers.length == 1 &&
                            taskController.selectedManagers.contains(
                              "Assign later",
                            ))
                    ? Text(
                      "Maximum 2 editors selected",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: hintTextColor.withOpacity(0.7),
                      ),
                    )
                    : null,
            validator: (value) {
              if (taskController.selectedManagers.isEmpty) {
                return "Please assign at least one editor or 'Assign later'";
              }
              if (taskController.selectedManagers.length == 1 &&
                  taskController.selectedManagers.contains("Assign later")) {
                return null;
              }
              if (!taskController.selectedManagers.contains("Assign later") &&
                  taskController.selectedManagers
                      .where((m) => m.isNotEmpty && m != "Assign later")
                      .isEmpty) {
                return "Please assign an editor.";
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 15),
        Obx(
          () => Column(
            children:
                taskController.selectedManagers.map((manager) {
                  final isAssignLater = manager == "Assign later";
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isAssignLater
                                          ? Colors.orange.withOpacity(
                                            isDark ? 0.25 : 0.15,
                                          )
                                          : fieldFillColor.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isAssignLater
                                            ? Colors.orange.shade600
                                            : inputFieldBorderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (isAssignLater)
                                      Icon(
                                        Icons.schedule_rounded,
                                        color: Colors.orange.shade600,
                                        size: 18,
                                      ),
                                    if (isAssignLater) const SizedBox(width: 8),
                                    Text(
                                      manager,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isAssignLater
                                                ? (isDark
                                                    ? Colors.orange.shade300
                                                    : Colors.orange.shade800)
                                                : textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red.shade600,
                                size: 20,
                              ),
                              onPressed:
                                  () => taskController.removeManager(manager),
                              tooltip: "Remove Editor",
                            ),
                          ],
                        ),
                        if (!isAssignLater) const SizedBox(height: 8),
                        if (!isAssignLater)
                          _buildInputField(
                            controller:
                                taskController.managerNotes[manager] ??
                                TextEditingController(), // Ensure controller exists
                            fieldFillColor: fieldFillColor,
                            textColor: textColor,
                            hintTextColor: hintTextColor,
                            borderColor: inputFieldBorderColor,
                            focusedBorderColor: inputFieldFocusedBorderColor,
                            hintText: "Add note for $manager (Optional)",
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
