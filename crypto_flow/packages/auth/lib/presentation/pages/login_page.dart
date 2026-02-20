import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/social_login_button.dart';

/// Login page with social sign-in options
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _privacyPolicyUrl =
      'https://www.tunckankilic.site/cryptowave-privacy-policy/';
  static const _termsOfServiceUrl =
      'https://www.tunckankilic.site/cryptowave-terms-of-service/';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: size.height - 100,
                  maxWidth: 480,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/1024.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App Name
                    Text(
                      'CryptoWave',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Real-time Cryptocurrency Tracker',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Welcome text
                    Text(
                      'Welcome',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to sync your portfolio and alerts across devices',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),
                    if (Platform.isAndroid) ...[
                      // Google Sign In
                      SocialLoginButton.google(
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<AuthBloc>()
                                .add(const AuthGoogleSignInRequested()),
                        isLoading: isLoading,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Apple Sign In (iOS only)
                    if (Platform.isIOS) ...[
                      SocialLoginButton.apple(
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<AuthBloc>()
                                .add(const AuthAppleSignInRequested()),
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Anonymous Sign In
                    SocialLoginButton.anonymous(
                      onPressed: isLoading
                          ? null
                          : () => context
                              .read<AuthBloc>()
                              .add(const AuthAnonymousSignInRequested()),
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Skip text
                    Text(
                      'You can sign in later from Settings',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Financial Disclaimer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This app is for informational purposes only and does not constitute financial advice.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms and Privacy — tappable links
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          children: [
                            const TextSpan(
                                text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchUrl(_termsOfServiceUrl),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchUrl(_privacyPolicyUrl),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            );
          },
        ),
      ),
    );
  }
}
