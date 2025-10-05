import 'package:farmmatrix/screens/language_selection/language_selection_screen.dart';
import 'package:flutter/material.dart';
    import 'package:farmmatrix/config/app_config.dart';
    import 'package:farmmatrix/screens/splash/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

    Future<void> main() async {
      WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bullrujvvqxyaptlijyy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1bGxydWp2dnF4eWFwdGxpanl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE3MjU1NjgsImV4cCI6MjA1NzMwMTU2OH0.YbysfUBDEHB4kFrSgvW4Dp5zWSySwo3lbvpvy3des9s',
  );
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