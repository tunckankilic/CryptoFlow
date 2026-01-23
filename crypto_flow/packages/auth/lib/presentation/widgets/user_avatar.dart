import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Avatar widget for displaying user profile image
class UserAvatar extends StatelessWidget {
  /// URL of the user's photo
  final String? photoUrl;

  /// User's display name (for fallback initials)
  final String? displayName;

  /// Size of the avatar
  final double size;

  /// Background color for fallback avatar
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.displayName,
    this.size = 48,
    this.backgroundColor,
  });

  String get _initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primary;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildFallback(bgColor),
          errorWidget: (_, __, ___) => _buildFallback(bgColor),
        ),
      );
    }

    return _buildFallback(bgColor);
  }

  Widget _buildFallback(Color bgColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
