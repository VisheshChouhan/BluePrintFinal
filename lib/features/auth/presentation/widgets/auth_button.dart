import 'package:blue_print/features/auth/presentation/widgets/general_text.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color buttonBackgroundColor;
  final Color textColor;
  final double fontSize;
  final double vertical;
  final double borderRadius;
  final String text;

  const AuthButton({
    super.key,
    required this.borderRadius,
    required this.onPressed,
    required this.vertical,
    required this.buttonBackgroundColor,
    required this.fontSize,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          padding: EdgeInsets.symmetric(vertical: vertical),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: GeneralText(
          text: text,
          fontSize: fontSize,
          color: textColor,
        ),
    );
  }
}
