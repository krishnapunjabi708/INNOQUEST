import 'package:flutter/material.dart';
import 'package:farmmatrix/config/app_config.dart';
import 'package:farmmatrix/widgets/common_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppConfig.authGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.only(top: 35),
                child: Image.asset(
                  'assets/images/logo2.png',
                  width: 200,
                  height: 150,
                ),
              ),
              const SizedBox(height: 70),
              // White container with login form
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 251, 246, 235),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Login Text
                        Text(
                          'Log In', // Placeholder, no localization
                          style: const TextStyle(
                            fontFamily: AppConfig.fontFamily,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 211, 136, 48),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Login Form
                        Form(
                          child: Column(
                            children: [
                              // Full Name Field
                              TextFormField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppConfig.accentColor,
                                  hintText: 'Full Name',
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Colors.black54,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Phone Number Field with Country Code
                              Row(
                                children: [
                                  // Country Code Picker (Static Placeholder)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppConfig.accentColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                    child: const Text(
                                      '+91',
                                      style: TextStyle(
                                        fontFamily: AppConfig.fontFamily,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Phone Number Input
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppConfig.accentColor,
                                        hintText: 'Phone Number',
                                        prefixIcon: const Icon(
                                          Icons.phone,
                                          color: Colors.black54,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  text: 'Log In',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder HomeScreen until implemented
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Screen Placeholder')),
    );
  }
}
