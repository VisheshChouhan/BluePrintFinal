import 'package:blue_print/assets/my_color_theme.dart';
import 'package:flutter/material.dart';

class ChoiceBox extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const ChoiceBox({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(150, 150),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: MyColorThemeTheme.whiteColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
    );
  }
}
