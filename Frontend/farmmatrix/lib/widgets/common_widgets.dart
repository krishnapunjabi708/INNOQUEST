import 'package:flutter/material.dart';
import 'package:farmmatrix/config/app_config.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: AppConfig.primaryButtonStyle,
      child: Text(text, style: AppConfig.buttonTextStyle),
    );
  }
}

class LanguageOption extends StatelessWidget {
  final String language;
  final String languageCode;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? flagWidget;

  const LanguageOption({
    super.key,
    required this.language,
    required this.languageCode,
    required this.isSelected,
    this.onTap,
    this.flagWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppConfig.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Flag
            if (flagWidget != null) ...[flagWidget!, const SizedBox(width: 16)],

            // Language Name
            Text(
              language,
              style: TextStyle(
                fontFamily: AppConfig.fontFamily,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),

            const Spacer(),

            // Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppConfig.primaryColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class CountryFlag extends StatelessWidget {
  final String countryCode;

  const CountryFlag({super.key, required this.countryCode});

  @override
  Widget build(BuildContext context) {
    // Use simple colored containers with text instead of custom painters
    if (countryCode == 'uk') {
      return Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.blue[900],
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            'UK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (countryCode == 'in') {
      return Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.orange,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            'IN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width:30,
      height: 20,
      color: Colors.grey,
      child: Center(
        child: Text(
          countryCode.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
