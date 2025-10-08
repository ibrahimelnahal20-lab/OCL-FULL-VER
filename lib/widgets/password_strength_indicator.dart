import 'package:flutter/material.dart';

enum PasswordStrength { veryWeak, weak, medium, strong, veryStrong }

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool isDarkMode;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    required this.isDarkMode,
  });

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.veryWeak;

    int score = 0;

    // Length check
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score += 1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;
    if (password.contains(RegExp(r'[0-9]'))) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1;

    // Additional complexity
    if (password.length >= 16) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
    }

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.veryWeak;
      case 2:
        return PasswordStrength.weak;
      case 3:
      case 4:
        return PasswordStrength.medium;
      case 5:
      case 6:
        return PasswordStrength.strong;
      default:
        return PasswordStrength.veryStrong;
    }
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return Colors.red;
      case PasswordStrength.weak:
        return Colors.orange;
      case PasswordStrength.medium:
        return Colors.yellow;
      case PasswordStrength.strong:
        return Colors.lightGreen;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }

  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return "Very Weak";
      case PasswordStrength.weak:
        return "Weak";
      case PasswordStrength.medium:
        return "Medium";
      case PasswordStrength.strong:
        return "Strong";
      case PasswordStrength.veryStrong:
        return "Very Strong";
    }
  }

  double _getStrengthPercentage(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 0.2;
      case PasswordStrength.weak:
        return 0.4;
      case PasswordStrength.medium:
        return 0.6;
      case PasswordStrength.strong:
        return 0.8;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    final strengthColor = _getStrengthColor(strength);
    final strengthText = _getStrengthText(strength);
    final strengthPercentage = _getStrengthPercentage(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: strengthPercentage,
            child: Container(
              decoration: BoxDecoration(
                color: strengthColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: strengthColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Strength text and requirements
        Row(
          children: [
            Text(
              "Strength: ",
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // Requirements checklist
        if (password.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildRequirementsList(password, isDarkMode),
        ],
      ],
    );
  }

  Widget _buildRequirementsList(String password, bool isDarkMode) {
    final requirements = [
      {'text': 'At least 8 characters', 'met': password.length >= 8},
      {
        'text': 'Contains lowercase letter',
        'met': password.contains(RegExp(r'[a-z]')),
      },
      {
        'text': 'Contains uppercase letter',
        'met': password.contains(RegExp(r'[A-Z]')),
      },
      {'text': 'Contains number', 'met': password.contains(RegExp(r'[0-9]'))},
      {
        'text': 'Contains special character',
        'met': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          requirements.map((requirement) {
            final isMet = requirement['met'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    isMet ? Icons.check_circle : Icons.circle_outlined,
                    size: 14,
                    color:
                        isMet
                            ? (isDarkMode
                                ? Colors.green[400]
                                : Colors.green[600])
                            : (isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    requirement['text'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isMet
                              ? (isDarkMode
                                  ? Colors.green[400]
                                  : Colors.green[600])
                              : (isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[600]),
                      fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
