import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settings/settings.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/page_indicator.dart';

/// Onboarding page for first-time users
class OnboardingPage extends StatefulWidget {
  final SettingsRepository settingsRepository;

  const OnboardingPage({
    super.key,
    required this.settingsRepository,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.currency_bitcoin,
      'title': 'Welcome to CryptoWave',
      'description': 'Track your favorite cryptocurrencies in real-time',
    },
    {
      'icon': Icons.show_chart,
      'title': 'Real-Time Market Data',
      'description': 'Get live prices, charts, and market insights',
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Price Alerts',
      'description': 'Never miss a price movement with custom alerts',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await widget.settingsRepository.markOnboardingAsSeen();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (!isLastPage)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: const Text('Skip'),
                ),
              ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingContent(
                    key: ValueKey(index),
                    icon: page['icon'] as IconData,
                    title: page['title'] as String,
                    description: page['description'] as String,
                  );
                },
              ),
            ),

            // Page indicator
            PageIndicator(
              currentPage: _currentPage,
              pageCount: _pages.length,
            ),
            const SizedBox(height: 32),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
