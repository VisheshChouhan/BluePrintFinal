import 'package:blue_print/features/auth/presentation/widgets/general_text.dart';
import 'package:flutter/material.dart';

class AuthTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const AuthTextButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: GeneralText(
          text: text,
        ),
    );
  }
}
