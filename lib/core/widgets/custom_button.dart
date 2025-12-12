import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF16A085),
        foregroundColor: Colors.white, 
        // Змінено: Зменшуємо вертикальний відступ
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          // Змінено: Зменшуємо розмір шрифту
          fontSize: 16, 
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(text),
    );
  }
}