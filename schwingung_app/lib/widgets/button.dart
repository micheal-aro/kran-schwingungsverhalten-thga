import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;

  const AppTextButton({
    super.key,
    this.icon,
    this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
