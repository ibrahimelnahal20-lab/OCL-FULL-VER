import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocl2/widgets/Notification/notification_controller.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  static const List<String> statusOptions = [
    'All Statuses',
    'Complete',
    'In Progress',
    'Not started',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NotificationController>();
    return Obx(() {
      final total = c.taskCount.value + c.subTaskCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Enhanced notification icon with better styling
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: total > 0 ? Colors.red.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border:
                  total > 0
                      ? Border.all(color: Colors.red.shade200, width: 1)
                      : null,
            ),
            child: IconButton(
              icon: Icon(
                total > 0
                    ? Icons.notifications_active
                    : Icons.notifications_outlined,
                color:
                    total > 0
                        ? Colors.red.shade600
                        : Theme.of(context).iconTheme.color,
                size: 24,
              ),
              onPressed: () => _showNotifications(context, c),
            ),
          ),
          // Enhanced notification badge
          if (total > 0)
            Positioned(right: 2, top: 2, child: _buildEnhancedBadge(total)),
        ],
      );
    });
  }

  Widget _buildEnhancedBadge(int count) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.red.shade500, Colors.red.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.red.shade300.withOpacity(0.4),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      count > 99 ? '99+' : '$count',
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  void _showNotifications(BuildContext context, NotificationController c) {
    final isDark = Get.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder:
                (_, scrollCtrl) => Obx(() {
                  final List<dynamic> list = c.filteredNotifications;
                  final isTask = c.selectedType.value == 'Task';
                  final baseTasks =
                      isTask ? c.notifications : c.subNotifications;

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isDark
                                ? [
                                  const Color(0xFF1A1A1A),
                                  const Color(0xFF2D2D2D),
                                  const Color(0xFF1A1A1A),
                                ]
                                : [
                                  Colors.white,
                                  Colors.grey.shade50,
                                  Colors.white,
                                ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Enhanced drag handle
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),

                        // Enhanced header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            isDark
                                                ? [
                                                  Colors.blue.shade600,
                                                  Colors.purple.shade600,
                                                ]
                                                : [
                                                  Colors.blue.shade500,
                                                  Colors.purple.shade500,
                                                ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.notifications_active,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Notifications',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.grey.shade800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Enhanced type selector buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedTypeButton(
                                  label: 'Tasks',
                                  count: c.taskCount.value,
                                  isSelected: isTask,
                                  onTap: () => c.setSelectedType('Task'),
                                  isDark: isDark,
                                  icon: Icons.assignment,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedTypeButton(
                                  label: 'SubTasks',
                                  count: c.subTaskCount.value,
                                  isSelected: !isTask,
                                  onTap: () => c.setSelectedType('SubTask'),
                                  isDark: isDark,
                                  icon: Icons.subtitles,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Enhanced status filter chips
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: statusOptions.length,
                            itemBuilder: (context, index) {
                              final status = statusOptions[index];
                              final sel = c.selectedStatus.value == status;
                              int cnt;
                              if (status == 'All Statuses') {
                                cnt = baseTasks.length;
                              } else {
                                final filter = _parseStatus(status);
                                cnt =
                                    baseTasks.where((item) {
                                      return isTask
                                          ? _parseStatus(
                                                (item
                                                    as Map<
                                                      String,
                                                      String
                                                    >)['taskStatus']!,
                                              ) ==
                                              filter
                                          : _parseStatus(
                                                (item as SubTaskModel).status,
                                              ) ==
                                              filter;
                                    }).length;
                              }
                              final col = _statusColor(
                                _parseStatus(status),
                                isDark,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildEnhancedStatusChip(
                                  status: status,
                                  count: cnt,
                                  isSelected: sel,
                                  color: col,
                                  isDark: isDark,
                                  onTap: () => c.setSelectedStatus(status),
                                ),
                              );
                            },
                          ),
                        ),

                        // Enhanced notifications list
                        Expanded(
                          child:
                              list.isEmpty
                                  ? _buildEmptyState(isDark)
                                  : ListView.separated(
                                    controller: scrollCtrl,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    separatorBuilder:
                                        (_, __) => const SizedBox(height: 16),
                                    itemCount: list.length,
                                    itemBuilder: (_, idx) {
                                      final item = list[idx];
                                      return isTask
                                          ? _buildEnhancedTaskCard(
                                            item as Map<String, String>,
                                            c,
                                            idx,
                                            isDark,
                                          )
                                          : _buildEnhancedSubTaskCard(
                                            item as SubTaskModel,
                                            c,
                                            idx,
                                            isDark,
                                          );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTypeButton({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors:
                        isDark
                            ? [Colors.blue.shade600, Colors.purple.shade600]
                            : [Colors.blue.shade500, Colors.purple.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color:
              isSelected
                  ? null
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected
                  ? null
                  : Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: (isDark ? Colors.blue : Colors.blue.shade400)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.grey.shade700),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.2)
                        : (isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatusChip({
    required String status,
    required int count,
    required bool isSelected,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withOpacity(isDark ? 0.3 : 0.2)
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color:
                      isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    isSelected
                        ? (isDark ? Colors.white : Colors.grey.shade800)
                        : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTaskCard(
    Map<String, String> note,
    NotificationController c,
    int idx,
    bool isDark,
  ) {
    final status = _parseStatus(note['taskStatus']!);
    final col = _statusColor(status, isDark);
    final isComplete = status == TaskStatus.complete;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [col.withOpacity(0.1), col.withOpacity(0.05)]
                  : [col.withOpacity(0.08), col.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: col.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: col.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.assignment, color: col, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    note['taskName']!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: col,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: col.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    note['taskStatus']!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEnhancedInfoRow(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: note['startDate']!,
              isDark: isDark,
            ),
            _buildEnhancedInfoRow(
              icon: Icons.schedule,
              label: 'Deadline',
              value: note['deadline']!,
              isDark: isDark,
            ),
            _buildEnhancedInfoRow(
              icon: Icons.note,
              label: 'Note',
              value: note['note']!,
              isDark: isDark,
            ),
            _buildEnhancedInfoRow(
              icon: Icons.person,
              label: 'Manager',
              value: note['projectManager']!,
              isDark: isDark,
            ),
            _buildEnhancedInfoRow(
              icon: Icons.account_circle,
              label: 'Created By',
              value: note['createdBy']!,
              isDark: isDark,
            ),
            if (isComplete)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        onPressed: () => c.removeNotification(idx),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSubTaskCard(
    SubTaskModel sub,
    NotificationController c,
    int idx,
    bool isDark,
  ) {
    final status = _parseStatus(sub.status);
    final col = _statusColor(status, isDark);
    final isComplete = status == TaskStatus.complete;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [col.withOpacity(0.1), col.withOpacity(0.05)]
                  : [col.withOpacity(0.08), col.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: col.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: col.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.subtitles, color: col, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sub.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: col,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: col.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    sub.status,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEnhancedInfoRow(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: sub.startDate,
              isDark: isDark,
            ),
            _buildEnhancedInfoRow(
              icon: Icons.schedule,
              label: 'Deadline',
              value: sub.deadlineDate,
              isDark: isDark,
            ),
            _buildEnhancedInfoRow(
              icon: Icons.person,
              label: 'Editor',
              value: sub.editor,
              isDark: isDark,
            ),
            _buildEnhancedInfoRow(
              icon: Icons.info,
              label: 'Status',
              value: sub.status,
              isDark: isDark,
            ),
            _buildEnhancedInfoRow(
              icon: Icons.note,
              label: 'Note',
              value: sub.note,
              isDark: isDark,
            ),
            if (isComplete)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        onPressed: () => c.removeNotification(idx),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white70 : Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  TaskStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'not started':
        return TaskStatus.notStarted;
      case 'in progress':
        return TaskStatus.inProgress;
      case 'complete':
        return TaskStatus.complete;
      case 'canceled':
        return TaskStatus.canceled;
      default:
        return TaskStatus.unknown;
    }
  }

  Color _statusColor(TaskStatus status, bool isDark) {
    if (isDark) {
      switch (status) {
        case TaskStatus.notStarted:
          return const Color(0xFFF39C12);
        case TaskStatus.inProgress:
          return const Color(0xFF3498DB);
        case TaskStatus.complete:
          return const Color(0xFF27AE60);
        case TaskStatus.canceled:
          return const Color(0xFFE74C3C);
        default:
          return const Color(0xFF95A5A6);
      }
    } else {
      switch (status) {
        case TaskStatus.notStarted:
          return Colors.orange;
        case TaskStatus.inProgress:
          return Colors.blue;
        case TaskStatus.complete:
          return Colors.green;
        case TaskStatus.canceled:
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
  }
}
