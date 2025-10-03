import 'package:flutter/material.dart';

    class AppConfig {
      // App Colors
      static const Color primaryColor = Color(0xFF1B413C);
      static const Color textColor = Color(0xFF333333);
      static const Color backgroundColor = Colors.white;

      // Text Styles
      static const String fontFamily = 'PlusJakartaSans';

      static TextStyle headingStyle = const TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      );

      static TextStyle buttonTextStyle = const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

      // Button Style
      static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      );
    }