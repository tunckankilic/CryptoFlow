import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';
import 'user_avatar.dart';

/// Header widget displaying user profile information
class ProfileHeader extends StatelessWidget {
  /// The authenticated user
  final AppUser user;

  /// Callback when edit button is pressed
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          UserAvatar(
            photoUrl: user.photoUrl,
            displayName: user.displayName,
            size: 96,
          ),
          const SizedBox(height: 16),

          // Display name
          Text(
            user.displayNameOrEmail,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          // Email (if different from display name)
          if (user.email != null &&
              user.email != user.displayName &&
              !user.isAnonymous)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                user.email!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 8),

          // Provider badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getProviderColor(user.provider).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getProviderIcon(user.provider),
                  size: 16,
                  color: _getProviderColor(user.provider),
                ),
                const SizedBox(width: 6),
                Text(
                  _getProviderLabel(user.provider),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getProviderColor(user.provider),
                  ),
                ),
              ],
            ),
          ),

          // Member since
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Member since ${_formatDate(user.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProviderIcon(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return Icons.g_mobiledata;
      case AuthProvider.apple:
        return Icons.apple;
      case AuthProvider.email:
        return Icons.email;
      case AuthProvider.anonymous:
        return Icons.person_outline;
    }
  }

  Color _getProviderColor(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return Colors.red.shade600;
      case AuthProvider.apple:
        return Colors.black;
      case AuthProvider.email:
        return Colors.blue.shade600;
      case AuthProvider.anonymous:
        return Colors.grey.shade600;
    }
  }

  String _getProviderLabel(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return 'Google Account';
      case AuthProvider.apple:
        return 'Apple Account';
      case AuthProvider.email:
        return 'Email Account';
      case AuthProvider.anonymous:
        return 'Guest Account';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
