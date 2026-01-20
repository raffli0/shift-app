import 'package:flutter/material.dart';

class AppDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String primaryButtonText = "Okay",
    VoidCallback? onPrimary,
    String? secondaryButtonText,
    VoidCallback? onSecondary,
    bool isDestructive = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white, // Ensure clean white background
        elevation: 0, // Flat premium feel
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              if (secondaryButtonText != null) ...[
                _buildButton(
                  context: context,
                  text: secondaryButtonText,
                  onTap: () {
                    Navigator.pop(context);
                    onSecondary?.call();
                  },
                  isPrimary: false,
                ),
                const SizedBox(height: 12),
              ],
              _buildButton(
                context: context,
                text: primaryButtonText,
                onTap: () {
                  Navigator.pop(context);
                  onPrimary?.call();
                },
                isPrimary: true,
                isDestructive: isDestructive,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
    required bool isPrimary,
    bool isDestructive = false,
  }) {
    final bgColor = isPrimary
        ? (isDestructive ? Colors.red.shade50 : const Color(0xff5a64d6))
        : Colors.transparent;
    final textColor = isPrimary
        ? (isDestructive ? Colors.red : Colors.white)
        : Colors.black54;

    if (!isPrimary) {
      // Secondary is purely text usually, or bordered?
      // User said "Secondary actions use neutral styling"
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: bgColor,
          boxShadow: isPrimary && !isDestructive
              ? [
                  BoxShadow(
                    color: const Color(0xff5a64d6).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }

  /// Preset: Success
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: "Okay",
    );
  }

  /// Preset: Error
  static Future<void> showError({
    required BuildContext context,
    String title = "Action not available",
    String message = "Please complete the previous step first.",
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: "Okay",
      // Could use simple alert style or sticking to the custom one
    );
  }
}
