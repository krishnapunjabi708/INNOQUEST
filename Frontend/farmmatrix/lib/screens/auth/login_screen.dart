import 'package:farmmatrix/screens/home/home_screen.dart';
import 'package:farmmatrix/services/auth_services.dart';
import 'package:flutter/material.dart';
    import 'package:farmmatrix/config/app_config.dart';
    import 'package:farmmatrix/widgets/common_widgets.dart';
    import 'package:geolocator/geolocator.dart';
    import 'package:country_code_picker/country_code_picker.dart';
    import 'package:shared_preferences/shared_preferences.dart';

    class LoginScreen extends StatefulWidget {
      const LoginScreen({super.key});

      @override
      State<LoginScreen> createState() => _LoginScreenState();
    }

    class _LoginScreenState extends State<LoginScreen> {
      final _formKey = GlobalKey<FormState>();
      final _nameController = TextEditingController();
      final _phoneController = TextEditingController();
      String _countryCode = '+91';
      bool _isLoading = false;

      @override
      void dispose() {
        _nameController.dispose();
        _phoneController.dispose();
        super.dispose();
      }

      Future<void> _handleLogin() async {
        if (!_formKey.currentState!.validate()) return;

        setState(() => _isLoading = true);

        try {
          // 1. Check and request location permissions
          await _checkLocationPermissions();

          // 2. Get current position
          final Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // 3. Create full phone number
          final String fullPhoneNumber = '$_countryCode${_phoneController.text}';

          // 4. Create or get existing user in database
          final userId = await AuthServices.createUser(
            phone: fullPhoneNumber,
            fullName: _nameController.text,
            latitude: position.latitude,
            longitude: position.longitude,
          );

          // 5. Verify user was created or exists
          if (userId == null) {
            throw Exception('User creation failed');
          }

          // 6. Store userId in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);

          // 7. Navigate to home screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }

      Future<void> _checkLocationPermissions() async {
        // Check if location service is enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          bool? shouldOpenSettings = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Location Services Disabled'),
                content: const Text('Please enable location services to continue.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: const Text('Open Settings'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          );

          if (shouldOpenSettings == true) {
            await Geolocator.openLocationSettings();
            serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              throw Exception('Location services are still disabled.');
            }
          } else {
            throw Exception('Location services are required.');
          }
        }

        // Check location permissions
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            bool? shouldOpenSettings = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Location Permission Required'),
                  content: const Text('This app needs location access to function properly.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Open Settings'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );

            if (shouldOpenSettings == true) {
              await Geolocator.openAppSettings();
              permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                throw Exception('Location permissions are still denied.');
              }
            } else {
              throw Exception('Location permissions are required.');
            }
          }
        }

        if (permission == LocationPermission.deniedForever) {
          bool? shouldOpenSettings = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Location Permission Permanently Denied'),
                content: const Text('Please enable location permissions in app settings.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: const Text('Open Settings'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          );

          if (shouldOpenSettings == true) {
            await Geolocator.openAppSettings();
            permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
              throw Exception('Location permissions are permanently denied.');
            }
          } else {
            throw Exception('Location permissions are required.');
          }
        }
      }

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
                              'Log In',
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
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Full Name Field
                                  TextFormField(
                                    controller: _nameController,
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Phone Number Field with Country Code
                                  Row(
                                    children: [
                                      // Country Code Picker
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppConfig.accentColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: CountryCodePicker(
                                          onChanged: (CountryCode code) {
                                            setState(() {
                                              _countryCode = code.dialCode!;
                                            });
                                          },
                                          initialSelection: 'IN',
                                          favorite: ['+91', 'IN'],
                                          showCountryOnly: false,
                                          showOnlyCountryWhenClosed: false,
                                          alignLeft: false,
                                          padding: EdgeInsets.zero,
                                          textStyle: const TextStyle(
                                            fontFamily: AppConfig.fontFamily,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Phone Number Input
                                      Expanded(
                                        child: TextFormField(
                                          controller: _phoneController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: AppConfig.accentColor,
                                            hintText: 'Phone Number',
                                            prefixIcon: const Icon(
                                              Icons.phone,
                                              color: Colors.black54,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          keyboardType: TextInputType.phone,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your phone number';
                                            }
                                            if (value.length < 10) {
                                              return 'Invalid phone number';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: PrimaryButton(
                                      text: _isLoading ? 'Processing...' : 'Log In',
                                      onPressed: _isLoading ? () {} : _handleLogin,
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

