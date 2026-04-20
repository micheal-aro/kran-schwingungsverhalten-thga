import 'package:flutter/material.dart';

enum TextFeldType { numeric, alphanumeric }

class TextFeld extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextFeldType textFeldType;
  final bool editable;

  const TextFeld({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.editable = true,
    this.textFeldType = TextFeldType.alphanumeric,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: textFeldType == TextFeldType.numeric
          ? TextInputType.number
          : TextInputType.text,
      enabled: editable,
    );
  }
}
