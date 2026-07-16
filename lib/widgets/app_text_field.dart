import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
