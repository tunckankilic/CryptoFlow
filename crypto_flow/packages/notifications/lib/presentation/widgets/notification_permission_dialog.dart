import 'package:flutter/material.dart';

/// Dialog to request notification permission
class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onMaybeLater;

  const NotificationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onMaybeLater,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications_active, size: 28),
          SizedBox(width: 12),
          Text('Enable Notifications'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay updated with real-time price alerts and portfolio changes.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          _BenefitItem(
            icon: Icons.trending_up,
            text: 'Get notified when your price targets are reached',
          ),
          SizedBox(height: 8),
          _BenefitItem(
            icon: Icons.account_balance_wallet,
            text: 'Track significant portfolio changes',
          ),
          SizedBox(height: 8),
          _BenefitItem(
            icon: Icons.settings,
            text: 'Customize notification preferences anytime',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onMaybeLater,
          child: const Text('Maybe Later'),
        ),
        FilledButton(
          onPressed: onAllow,
          child: const Text('Allow'),
        ),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
