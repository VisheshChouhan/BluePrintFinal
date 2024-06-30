import 'package:flutter/material.dart';

import '../../../../../assets/my_color_theme.dart';

class Subjects extends StatelessWidget {
  final VoidCallback onPressed;
  final String text1;
  final String text2;
  const Subjects(
      {super.key,
      required this.onPressed,
      required this.text1,
      required this.text2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(150, 150),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: BorderSide(width: 0.2),),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text1,
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Text(
                text2,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
