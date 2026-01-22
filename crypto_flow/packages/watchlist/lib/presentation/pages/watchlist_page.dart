import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import '../widgets/watchlist_tile.dart';

/// Watchlist page displaying user's favorite cryptocurrencies
class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to search page to add coins
            },
          ),
        ],
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state is WatchlistInitial) {
            context.read<WatchlistBloc>().add(const LoadWatchlist());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WatchlistLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WatchlistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WatchlistBloc>().add(const LoadWatchlist());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WatchlistLoaded) {
            if (state.items.isEmpty) {
              return const _EmptyWatchlist();
            }

            return ReorderableListView.builder(
              itemCount: state.items.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final items = List.of(state.items);
                final item = items.removeAt(oldIndex);
                items.insert(newIndex, item);
                context.read<WatchlistBloc>().add(ReorderWatchlistEvent(items));
              },
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Dismissible(
                  key: ValueKey(item.symbol),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    context.read<WatchlistBloc>().add(
                          RemoveFromWatchlistEvent(item.symbol),
                        );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: WatchlistTile(
                    key: ValueKey(item.symbol),
                    item: item,
                    onTap: () {
                      Navigator.pushNamed(context, '/ticker/${item.symbol}');
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add cryptocurrencies to track them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to search page
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Coins'),
          ),
        ],
      ),
    );
  }
}
