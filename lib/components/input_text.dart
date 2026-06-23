import 'package:combustivel_ap/theme/app_colors.dart';
import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;

  const InputText({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        fillColor: AppColors.secondary,
        filled: true,
        labelText: labelText,
        labelStyle: TextStyle(
          color: AppColors.disabled,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.disabled,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}