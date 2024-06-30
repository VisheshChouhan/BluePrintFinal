import 'package:blue_print/features/auth/presentation/widgets/auth_text_button.dart';
import 'package:blue_print/features/auth/presentation/widgets/general_text.dart';
import 'package:flutter/cupertino.dart';

class AuthBottomText extends StatelessWidget {
  final String generalText;
  final String buttonText;
  final VoidCallback onPressed;
  const AuthBottomText({
    super.key,
    required this.buttonText,
    required this.generalText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GeneralText(
            text: generalText,
        ),
        AuthTextButton(
            onPressed: onPressed,
            text: buttonText,
        ),
      ],
    );
  }
}
