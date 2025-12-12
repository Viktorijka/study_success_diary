// import 'package:flutter/material.dart';

// // Виносимо кольори та тему в окремий клас для чистоти коду.
// class AppTheme {
//   // Визначаємо наші кольори як статичні константи
//   static const Color primaryDarkGreen = Color(0xFF156254);
//   static const Color accentGreen = Color(0xFF16A085);
//   static const Color lightBg = Color(0xFFF3F6F5);
//   static const Color darkGrey = Color(0xFF2D3735);

//   // Створюємо статичний метод, який повертає нашу тему
//   static ThemeData get lightTheme {
//     return ThemeData(
//       scaffoldBackgroundColor: lightBg,
//       fontFamily: 'Inter',
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: accentGreen,
//         primary: primaryDarkGreen,
//         surface: lightBg,
//       ),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: primaryDarkGreen,
//         foregroundColor: Colors.white,
//       ),
//       cardTheme: CardThemeData(
//         elevation: 4.0,
//         color: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryDarkGreen = Color(0xFF156254);
  static const Color accentGreen = Color(0xFF16A085);
  static const Color lightBg = Color(0xFFF3F6F5);
  static const Color darkGrey = Color(0xFF2D3735);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryDarkGreen,
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentGreen,
        brightness: Brightness.light,
        primary: primaryDarkGreen,
        secondary: accentGreen,
        surface: Colors.white,
        onSurface: darkGrey,
      ),
      cardTheme: CardThemeData( // ВИПРАВЛЕНО
        elevation: 0.0,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}