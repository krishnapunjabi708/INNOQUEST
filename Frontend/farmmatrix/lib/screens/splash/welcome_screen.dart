import 'package:flutter/material.dart';
    import 'package:farmmatrix/config/app_config.dart';
    import 'package:farmmatrix/widgets/common_widgets.dart';

    class WelcomeScreen extends StatelessWidget {
      const WelcomeScreen({super.key});

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Stack(
            children: [
              // Background Image with Opacity
              Opacity(
                opacity: 0.65,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppConfig.primaryColor.withOpacity(0.3),
                  child: Image.asset(
                    'assets/images/bg_Image.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppConfig.primaryColor.withOpacity(0.3),
                        child: Center(
                          child: Icon(
                            Icons.landscape,
                            size: 100,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo and Tagline
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            Image.asset('assets/images/logo.png', width: 200, height: 140),
                            // Tagline
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Welcome to FarmMatrix - Your Smart Farming Solution',
                                textAlign: TextAlign.center,
                                style: AppConfig.headingStyle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Get Started Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40, left: 32, right: 32),
                        child: PrimaryButton(
                          text: 'Get Started',
                          onPressed: () {
                            // Placeholder for navigation
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }