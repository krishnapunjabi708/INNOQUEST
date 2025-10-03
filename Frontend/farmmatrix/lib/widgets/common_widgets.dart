import 'package:flutter/material.dart';
    import 'package:farmmatrix/config/app_config.dart';

    class PrimaryButton extends StatelessWidget {
      final String text;
      final VoidCallback onPressed;

      const PrimaryButton({
        super.key,
        required this.text,
        required this.onPressed,
      });

      @override
      Widget build(BuildContext context) {
        return ElevatedButton(
          onPressed: onPressed,
          style: AppConfig.primaryButtonStyle,
          child: Text(
            text,
            style: AppConfig.buttonTextStyle,
          ),
        );
      }
    }