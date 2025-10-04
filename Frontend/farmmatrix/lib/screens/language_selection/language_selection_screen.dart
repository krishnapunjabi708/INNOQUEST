import 'package:flutter/material.dart';
    import 'package:farmmatrix/config/app_config.dart';
    import 'package:farmmatrix/widgets/common_widgets.dart';

    class LanguageSelectionScreen extends StatelessWidget {
      const LanguageSelectionScreen({super.key});

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: AppConfig.backgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset('assets/images/logo.png', width: 200, height: 140),
                  ),
                  const SizedBox(height: 32),

                  // Language Selection Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppConfig.accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          'Select Language', // Placeholder, no localization
                          style: TextStyle(
                            fontFamily: AppConfig.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Language Options (Static, no state changes)
                  const LanguageOption(
                    language: "English",
                    languageCode: 'en',
                    isSelected: true, // Default selected
                    onTap: null, // No action
                    flagWidget: CountryFlag(countryCode: 'uk'),
                  ),
                  const SizedBox(height: 12),
                  const LanguageOption(
                    language: "हिंदी",
                    languageCode: 'hi',
                    isSelected: false,
                    onTap: null, // No action
                    flagWidget: CountryFlag(countryCode: 'in'),
                  ),
                  const SizedBox(height: 12),
                  const LanguageOption(
                    language: "मराठी",
                    languageCode: 'mr',
                    isSelected: false,
                    onTap: null, // No action
                    flagWidget: CountryFlag(countryCode: 'in'),
                  ),

                  const Spacer(),

                  // Next Button
                  PrimaryButton(
                    text: 'Next',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Placeholder LoginScreen until implemented
    class LoginScreen extends StatelessWidget {
      const LoginScreen({super.key});

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: const Center(child: Text('Login Screen Placeholder')),
        );
      }
    }