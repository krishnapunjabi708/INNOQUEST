import 'package:farmmatrix/screens/language_selection/language_selection_screen.dart';
import 'package:flutter/material.dart';
    import 'package:farmmatrix/config/app_config.dart';
    import 'package:farmmatrix/screens/splash/welcome_screen.dart';

    void main() {
      runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {
      const MyApp({super.key});

      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          title: 'FarmMatrix',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppConfig.primaryColor,
            scaffoldBackgroundColor: AppConfig.backgroundColor,
            textTheme: TextTheme(
              headlineMedium: AppConfig.headingStyle,
              labelLarge: AppConfig.buttonTextStyle,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: AppConfig.primaryButtonStyle,
            ),
          ),
          home: const WelcomeScreen(),
          routes: {
            '/language': (context) => const LanguageSelectionScreen(),
          },
        );
      }
    }