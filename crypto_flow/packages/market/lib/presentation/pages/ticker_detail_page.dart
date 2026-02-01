import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:watchlist/watchlist.dart';
import 'package:alerts/alerts.dart';
import 'package:core/core.dart';
import '../../domain/entities/ticker.dart';
import '../bloc/ticker_detail/ticker_detail_bloc.dart';
import '../bloc/ticker_detail/ticker_detail_event.dart';
import '../bloc/ticker_detail/ticker_detail_state.dart';
import '../widgets/interval_selector.dart';
import '../widgets/order_book_ladder.dart';

/// Detail page for a single ticker
class TickerDetailPage extends StatefulWidget {
  final String symbol;

  const TickerDetailPage({super.key, required this.symbol});

  @override
  State<TickerDetailPage> createState() => _TickerDetailPageState();
}

class _TickerDetailPageState extends State<TickerDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TickerDetailBloc, TickerDetailState>(
      builder: (context, state) {
        if (state is TickerDetailInitial) {
          // Trigger load
          context.read<TickerDetailBloc>()
            ..add(LoadTickerDetail(widget.symbol))
            ..add(SubscribeToTickerUpdates(widget.symbol))
            ..add(SubscribeToOrderBook(widget.symbol));
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TickerDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TickerDetailError) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.symbol)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<TickerDetailBloc>()
                          .add(LoadTickerDetail(widget.symbol));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TickerDetailLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: _buildTitle(state.ticker),
              actions: [
                // Watchlist toggle button
                BlocBuilder<WatchlistBloc, WatchlistState>(
                  builder: (context, watchlistState) {
                    final isInWatchlist = watchlistState is WatchlistLoaded &&
                        (watchlistState.inWatchlistCache[widget.symbol] ??
                            false);

                    return IconButton(
                      icon: Icon(
                        isInWatchlist ? Icons.star : Icons.star_border,
                      ),
                      onPressed: () {
                        if (isInWatchlist) {
                          // Remove from watchlist
                          context
                              .read<WatchlistBloc>()
                              .add(RemoveFromWatchlistEvent(widget.symbol));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Removed ${widget.symbol} from watchlist'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          // Add to watchlist
                          context
                              .read<WatchlistBloc>()
                              .add(AddToWatchlistEvent(widget.symbol));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Added ${widget.symbol} to watchlist'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    _showCreateAlertSheet(context, widget.symbol);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    ShareService().shareTicker(
                      widget.symbol,
                      state.ticker.price,
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Price card
                _PriceCard(ticker: state.ticker),

                // Interval selector
                IntervalSelector(
                  currentInterval: state.interval,
                  onIntervalChanged: (interval) {
                    context
                        .read<TickerDetailBloc>()
                        .add(ChangeInterval(interval));
                  },
                ),

                // Tabs
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Chart'),
                    Tab(text: 'Order Book'),
                    Tab(text: 'Info'),
                  ],
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Chart tab
                      _ChartTab(candles: state.candles),

                      // Order book tab
                      state.orderBook != null
                          ? OrderBookLadder(orderBook: state.orderBook!)
                          : const Center(
                              child: Text('Loading order book...'),
                            ),

                      // Info tab
                      _InfoTab(ticker: state.ticker),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTitle(Ticker ticker) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(ticker.baseAsset),
        Text(
          '/${ticker.quoteAsset}',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showCreateAlertSheet(BuildContext context, String symbol) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateAlertSheet(),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final Ticker ticker;

  const _PriceCard({required this.ticker});

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.priceChangePercent >= 0;
    final color = isPositive ? CryptoColors.priceUp : CryptoColors.priceDown;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PriceText(
                  price: ticker.price,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    PercentChange(
                      percent: ticker.priceChangePercent,
                      showIcon: true,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${isPositive ? '+' : ''}${ticker.priceChange.toStringAsFixed(2)}',
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatRow(
                label: '24h High',
                value: ticker.high24h.toStringAsFixed(2),
              ),
              const SizedBox(height: 4),
              _StatRow(
                label: '24h Low',
                value: ticker.low24h.toStringAsFixed(2),
              ),
              const SizedBox(height: 4),
              _StatRow(
                label: '24h Vol',
                value: _formatVolume(ticker.volume),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1e9) return '${(volume / 1e9).toStringAsFixed(2)}B';
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(2)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(2)}K';
    return volume.toStringAsFixed(2);
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ChartTab extends StatelessWidget {
  final List<dynamic> candles;

  const _ChartTab({required this.candles});

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return const Center(child: Text('No chart data'));
    }

    // Use CandleChart from design_system if available
    // Cast to the expected type
    return CandleChart(candles: candles.cast());
  }
}

class _InfoTab extends StatelessWidget {
  final Ticker ticker;

  const _InfoTab({required this.ticker});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoTile(label: 'Symbol', value: ticker.symbol),
          _InfoTile(label: 'Base Asset', value: ticker.baseAsset),
          _InfoTile(label: 'Quote Asset', value: ticker.quoteAsset),
          _InfoTile(
            label: '24h Change',
            value:
                '${ticker.priceChange.toStringAsFixed(4)} (${ticker.priceChangePercent.toStringAsFixed(2)}%)',
          ),
          _InfoTile(
            label: '24h Volume',
            value: '${ticker.volume.toStringAsFixed(2)} ${ticker.baseAsset}',
          ),
          _InfoTile(
            label: 'Quote Volume',
            value:
                '${ticker.quoteVolume.toStringAsFixed(2)} ${ticker.quoteAsset}',
          ),
          _InfoTile(
            label: 'Number of Trades',
            value: ticker.trades.toString(),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
