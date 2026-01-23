import 'package:flutter/material.dart';

/// A styled button for social login providers
class SocialLoginButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Icon widget (typically Image.asset or Icon)
  final Widget icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button background color
  final Color backgroundColor;

  /// Text color
  final Color textColor;

  /// Whether the button is in loading state
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.isLoading = false,
  });

  /// Factory constructor for Google Sign In button
  factory SocialLoginButton.google({
    Key? key,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialLoginButton(
      key: key,
      label: 'Continue with Google',
      icon: Image.network(
        'https://www.google.com/favicon.ico',
        width: 24,
        height: 24,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.g_mobiledata,
          size: 24,
          color: Colors.red,
        ),
      ),
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  /// Factory constructor for Apple Sign In button
  factory SocialLoginButton.apple({
    Key? key,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialLoginButton(
      key: key,
      label: 'Continue with Apple',
      icon: const Icon(
        Icons.apple,
        size: 24,
        color: Colors.white,
      ),
      backgroundColor: Colors.black,
      textColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  /// Factory constructor for Anonymous Sign In button
  factory SocialLoginButton.anonymous({
    Key? key,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialLoginButton(
      key: key,
      label: 'Continue as Guest',
      icon: const Icon(
        Icons.person_outline,
        size: 24,
        color: Colors.white70,
      ),
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: backgroundColor == Colors.white
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
