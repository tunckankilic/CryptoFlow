import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import '../bloc/ticker_list/ticker_list_bloc.dart';
import '../bloc/ticker_list/ticker_list_event.dart';
import '../bloc/ticker_list/ticker_list_state.dart';
import '../widgets/ticker_list_tile.dart';

/// Main market list page showing all tickers
class MarketListPage extends StatefulWidget {
  const MarketListPage({super.key});

  @override
  State<MarketListPage> createState() => _MarketListPageState();
}

class _MarketListPageState extends State<MarketListPage> {
  final _searchController = TextEditingController();
  final _quoteAssets = ['All', 'USDT', 'BTC', 'ETH', 'BNB'];
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status bar
          BlocBuilder<TickerListBloc, TickerListState>(
            buildWhen: (prev, curr) =>
                prev is TickerListLoaded &&
                curr is TickerListLoaded &&
                (prev).connectionStatus != (curr).connectionStatus,
            builder: (context, state) {
              if (state is TickerListLoaded) {
                return _ConnectionStatusBar(status: state.connectionStatus);
              }
              return const SizedBox.shrink();
            },
          ),

          // Quote asset tabs
          _QuoteAssetTabs(
            assets: _quoteAssets,
            selectedIndex: _selectedTabIndex,
            onSelect: (index) {
              setState(() => _selectedTabIndex = index);
              final filter = index == 0 ? null : _quoteAssets[index];
              context.read<TickerListBloc>().add(FilterTickers(
                    quoteAsset: filter,
                  ));
            },
          ),

          // Ticker list
          Expanded(
            child: BlocBuilder<TickerListBloc, TickerListState>(
              builder: (context, state) {
                if (state is TickerListInitial) {
                  // Trigger initial load
                  context.read<TickerListBloc>()
                    ..add(const LoadTickers())
                    ..add(const SubscribeToTickers());
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TickerListLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is TickerListError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () {
                      context.read<TickerListBloc>().add(const LoadTickers());
                    },
                  );
                }

                if (state is TickerListLoaded) {
                  if (state.filteredTickers.isEmpty) {
                    return const Center(
                      child: Text('No tickers found'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TickerListBloc>().add(const LoadTickers());
                    },
                    child: ListView.builder(
                      itemCount: state.filteredTickers.length,
                      itemBuilder: (context, index) {
                        final ticker = state.filteredTickers[index];
                        return TickerListTile(
                          ticker: ticker,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/ticker/${ticker.symbol}',
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter symbol...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (query) {
            context.read<TickerListBloc>().add(SearchTickers(query));
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              context.read<TickerListBloc>().add(const ClearSearch());
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _SortOption(
              title: 'Volume (High to Low)',
              onTap: () {
                context.read<TickerListBloc>().add(const FilterTickers(
                      sortBy: TickerSortBy.volume,
                      ascending: false,
                    ));
                Navigator.pop(sheetContext);
              },
            ),
            _SortOption(
              title: 'Price Change (%)',
              onTap: () {
                context.read<TickerListBloc>().add(const FilterTickers(
                      sortBy: TickerSortBy.change,
                      ascending: false,
                    ));
                Navigator.pop(sheetContext);
              },
            ),
            _SortOption(
              title: 'Symbol (A-Z)',
              onTap: () {
                context.read<TickerListBloc>().add(const FilterTickers(
                      sortBy: TickerSortBy.symbol,
                      ascending: true,
                    ));
                Navigator.pop(sheetContext);
              },
            ),
            _SortOption(
              title: 'Price (High to Low)',
              onTap: () {
                context.read<TickerListBloc>().add(const FilterTickers(
                      sortBy: TickerSortBy.price,
                      ascending: false,
                    ));
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStatusBar extends StatelessWidget {
  final dynamic status;

  const _ConnectionStatusBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final isConnected = status.toString().contains('connected');
    final isError = status.toString().contains('error');

    if (isConnected) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      color: isError ? Colors.red.shade100 : Colors.orange.shade100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.sync,
            size: 16,
            color: isError ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            isError ? 'Connection error' : 'Reconnecting...',
            style: TextStyle(
              fontSize: 12,
              color: isError ? Colors.red : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteAssetTabs extends StatelessWidget {
  final List<String> assets;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _QuoteAssetTabs({
    required this.assets,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(assets[index]),
              selected: isSelected,
              onSelected: (_) => onSelect(index),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SortOption({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }
}
