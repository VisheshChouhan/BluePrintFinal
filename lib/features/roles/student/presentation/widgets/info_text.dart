import 'package:flutter/cupertino.dart';

class InfoText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const InfoText({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
    );
  }
}
