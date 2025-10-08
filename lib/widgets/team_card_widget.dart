// lib/widgets/team_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class TeamCardWidget extends StatelessWidget {
  final String name;
  final String jobTitle;
  final String description;
  final String imageUrl;
  final String userType;
  final bool isPinned;
  final int allTasks;
  final int completedTasks;

  const TeamCardWidget({
    super.key,
    required this.name,
    required this.jobTitle,
    required this.description,
    required this.imageUrl,
    required this.userType,
    this.isPinned = false,
    this.allTasks = 0,
    this.completedTasks = 0,
  });

  // Enhanced color scheme for better visual appeal
  static const Color dmCardBackgroundColor = Color(0xFF1A1F35);
  static const Color dmCircleAvatarBackgroundColor = Color(0xFF2D3748);
  static final Color dmTextColorPrimary = Colors.white.withOpacity(0.87);
  static final Color dmTextColorSecondary = Colors.grey[400]!;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    // Enhanced color definitions
    final Color cardColor = isDarkMode ? dmCardBackgroundColor : Colors.white;
    final Color textColorPrimary =
        isDarkMode ? dmTextColorPrimary : Colors.grey.shade800;
    final Color textColorSecondary =
        isDarkMode ? dmTextColorSecondary : Colors.grey.shade600;
    final Color accentColor =
        isDarkMode ? Colors.teal.shade400 : Colors.teal.shade500;
    final Color circleAvatarBgColor =
        isDarkMode ? dmCircleAvatarBackgroundColor : Colors.grey.shade200;

    String finalDescription =
        (description.isEmpty || description.toLowerCase() == "string")
            ? "No description available."
            : description;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [cardColor.withOpacity(0.9), cardColor.withOpacity(0.7)]
                      : [cardColor, cardColor.withOpacity(0.95)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.grey.shade700.withOpacity(0.3)
                      : Colors.grey.shade200.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    // Enhanced header section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textColorPrimary,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                jobTitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: accentColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withOpacity(0.2),
                                accentColor.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            userType,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Enhanced avatar section
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.2),
                            accentColor.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: circleAvatarBgColor,
                        backgroundImage:
                            imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        onBackgroundImageError:
                            imageUrl.isNotEmpty ? (_, __) {} : null,
                        child:
                            imageUrl.isEmpty
                                ? Icon(
                                  Icons.person_outline,
                                  color: Colors.grey[isDarkMode ? 500 : 400],
                                  size: 32,
                                )
                                : null,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Enhanced description section
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.grey.shade800.withOpacity(0.3)
                                : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              isDarkMode
                                  ? Colors.grey.shade700.withOpacity(0.2)
                                  : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        finalDescription,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: textColorSecondary,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Enhanced task statistics section
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDarkMode
                              ? [
                                Colors.grey.shade800.withOpacity(0.3),
                                Colors.grey.shade700.withOpacity(0.2),
                              ]
                              : [Colors.grey.shade50, Colors.grey.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isDarkMode
                              ? Colors.grey.shade700.withOpacity(0.3)
                              : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildEnhancedTaskInfo(
                        "All Tasks",
                        allTasks,
                        isDarkMode,
                        "assets/icons/AllTask.svg",
                        textColorPrimary,
                        textColorSecondary,
                        Colors.blue.shade400,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color:
                            isDarkMode
                                ? Colors.grey.shade600.withOpacity(0.3)
                                : Colors.grey.shade300,
                      ),
                      _buildEnhancedTaskInfo(
                        "Completed",
                        completedTasks,
                        isDarkMode,
                        "assets/icons/AllTask.svg",
                        textColorPrimary,
                        textColorSecondary,
                        Colors.green.shade400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Enhanced pinned indicator
        if (isPinned)
          Positioned(
            top: -6,
            left: -6,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade400.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.push_pin,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedTaskInfo(
    String title,
    int count,
    bool isDarkMode,
    String iconPath,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color accentColor,
  ) {
    bool iconExists = iconPath.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (iconExists)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SvgPicture.asset(
              iconPath,
              height: 16,
              width: 16,
              colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
