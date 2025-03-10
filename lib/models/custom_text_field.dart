import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final IconData? suffixIcon;
  final TextEditingController? controller; // Optional controller

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.suffixIcon,
    this.controller, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Use the controller if provided
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: const Color(0xFFF1F4FD),
        prefixIcon: Icon(icon, color: Colors.black54),
        suffixIcon:
        suffixIcon != null ? Icon(suffixIcon, color: Colors.black54) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }
}
