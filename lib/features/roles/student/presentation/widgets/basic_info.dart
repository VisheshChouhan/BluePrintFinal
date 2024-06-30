import 'package:blue_print/assets/my_color_theme.dart';
import 'package:flutter/material.dart';

class BasicInfo extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? iconData;
  const BasicInfo({super.key, required this.onPressed, required this.text, this.iconData});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(double.infinity, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0),),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
        ),

        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: Theme.of(context).textTheme.bodyLarge,),
            Icon(iconData),
          ],
        ),
    );
  }
}
