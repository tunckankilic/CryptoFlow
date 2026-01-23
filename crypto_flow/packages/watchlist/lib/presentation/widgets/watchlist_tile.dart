import 'package:flutter/material.dart';
import '../../domain/entities/watchlist_item.dart';

/// Watchlist tile widget displaying a cryptocurrency in the watchlist
class WatchlistTile extends StatelessWidget {
  final WatchlistItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const WatchlistTile({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        child: Text(
          item.symbol.length >= 3 ? item.symbol.substring(0, 3) : item.symbol,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      title: Text(
        item.symbol,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Added ${_formatTimeAgo(item.addedAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: ReorderableDragStartListener(
        index: item.order,
        child: const Icon(Icons.drag_handle),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 365) {
      return '${diff.inDays ~/ 365}y ago';
    } else if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
