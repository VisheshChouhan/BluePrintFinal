import 'package:blue_print/assets/my_color_theme.dart';
import 'package:flutter/material.dart';
class HomePageOption extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const HomePageOption({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(double.infinity, 70),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: BorderSide(width: 0.2),),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25,
            color: MyColorThemeTheme.whiteColor,
          ),
        ),
      ),
    );
  }
}
