import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final Widget prefixIcon;
  final String labelText;
  final String hintText;
  final double borderRadius;
  final bool obscureText;
  final TextEditingController controller;
  Widget? suffixIcon;
  AuthTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.borderRadius,
    required this.prefixIcon,
    required this.obscureText,
    required this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
