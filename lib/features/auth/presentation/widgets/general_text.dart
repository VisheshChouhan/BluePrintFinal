import 'package:flutter/material.dart';
class GeneralText extends StatelessWidget {
  final String text;
  final double? fontSize;
  Color? color;
  FontWeight? fontWeight = FontWeight.normal;
  TextAlign? textAlign;
  GeneralText({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}
