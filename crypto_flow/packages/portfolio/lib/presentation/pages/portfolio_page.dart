import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/portfolio_bloc.dart';
import '../bloc/portfolio_event.dart';
import '../bloc/portfolio_state.dart';
import '../bloc/journal/journal_bloc.dart';
import '../bloc/journal/journal_event.dart';
import '../bloc/journal_stats/journal_stats_bloc.dart';
import '../bloc/journal_stats/journal_stats_event.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/holding_tile.dart';
import '../widgets/allocation_pie_chart.dart';
import 'add_transaction_page.dart';
import 'journal/journal_list_page.dart';
import 'journal/analytics_page.dart';
import 'package:design_system/design_system.dart';
import '../../domain/entities/stats_period.dart';

/// Portfolio page with tabbed interface: Holdings, Journal, Analytics
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with SingleTickerProviderStateMixin {
  static const String _title = 'Portfolio';
  static const String _holdingsTab = 'Holdings';
  static const String _journalTab = 'Journal';
  static const String _analyticsTab = 'Analytics';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data based on current tab
              if (_tabController.index == 0) {
                context.read<PortfolioBloc>().add(const RefreshPrices());
              } else if (_tabController.index == 1) {
                context
                    .read<JournalBloc>()
                    .add(const JournalEntriesRequested());
              } else if (_tabController.index == 2) {
                context
                    .read<JournalStatsBloc>()
                    .add(const JournalStatsRequested(StatsPeriod.allTime));
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: _holdingsTab, icon: Icon(Icons.account_balance_wallet)),
            Tab(text: _journalTab, icon: Icon(Icons.book)),
            Tab(text: _analyticsTab, icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HoldingsTab(),
          const JournalListPage(),
          const AnalyticsPage(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<PortfolioBloc>(),
                      child: const AddTransactionPage(),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

/// Holdings tab showing portfolio summary and holdings
class _HoldingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PortfolioError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading portfolio',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<PortfolioBloc>().add(const LoadPortfolio());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is PortfolioLoaded) {
          if (state.holdings.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PortfolioBloc>().add(const RefreshPrices());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: CustomScrollView(
              slivers: [
                // Summary card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.paddingMD,
                    child: PortfolioSummaryCard(summary: state.summary),
                  ),
                ),

                // Allocation chart
                if (state.summary.allocation.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppSpacing.paddingMD,
                      child: AllocationPieChart(
                        allocation: state.summary.allocation,
                      ),
                    ),
                  ),

                // Holdings section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.paddingMD,
                    child: Text(
                      'Holdings',
                      style: AppTypography.h4,
                    ),
                  ),
                ),

                // Holdings list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final holding = state.holdings[index];
                      final currentPrice =
                          state.currentPrices[holding.symbol] ?? 0;

                      return HoldingTile(
                        holding: holding,
                        currentPrice: currentPrice,
                      );
                    },
                    childCount: state.holdings.length,
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            'No holdings yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Add your first transaction to start tracking'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<PortfolioBloc>(),
                    child: const AddTransactionPage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}
