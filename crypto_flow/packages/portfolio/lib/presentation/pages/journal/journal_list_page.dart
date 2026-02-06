import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import '../../bloc/journal/journal_bloc.dart';
import '../../bloc/journal/journal_event.dart';
import '../../bloc/journal/journal_state.dart';
import '../../bloc/journal/journal_filter.dart';
import '../../bloc/journal/journal_sort.dart';
import '../../bloc/journal_stats/journal_stats_bloc.dart';
import '../../bloc/journal_stats/journal_stats_state.dart';
import '../../widgets/journal/quick_stats_widget.dart';
import '../../widgets/journal/journal_entry_card.dart';

/// Journal list page showing all journal entries with filtering and search
class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  static const String _title = 'Trading Journal';
  static const String _searchHint = 'Search symbol, strategy, or tags';
  static const String _emptyStateTitle = 'No trades logged yet';
  static const String _emptyStateSubtitle = 'Start journaling!';
  static const String _addButton = 'Add Entry';
  static const String _allFilter = 'All';
  static const String _winsFilter = 'Wins';
  static const String _lossesFilter = 'Losses';
  static const String _longFilter = 'Long';
  static const String _shortFilter = 'Short';
  static const String _sortByDate = 'Date';
  static const String _sortByPnl = 'P&L';
  static const String _sortByRR = 'R:R';
  static const String _deleteConfirmTitle = 'Delete Entry';
  static const String _deleteConfirmMessage =
      'Are you sure you want to delete this journal entry?';
  static const String _deleteButton = 'Delete';
  static const String _cancelButton = 'Cancel';

  final TextEditingController _searchController = TextEditingController();
  JournalFilter _selectedFilter = JournalFilter.all;
  JournalSort _selectedSort = JournalSort.dateDesc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: AppSpacing.paddingMD,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<JournalBloc>()
                                  .add(const JournalSearched(''));
                            },
                          )
                        : null,
                  ),
                  onChanged: (query) {
                    context.read<JournalBloc>().add(JournalSearched(query));
                  },
                ),
              ),

              // Filter chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  children: [
                    _buildFilterChip(_allFilter, JournalFilter.all),
                    _buildFilterChip(_winsFilter, JournalFilter.wins),
                    _buildFilterChip(_lossesFilter, JournalFilter.losses),
                    _buildFilterChip(_longFilter, JournalFilter.long),
                    _buildFilterChip(_shortFilter, JournalFilter.short),
                    const SizedBox(width: AppSpacing.sm),
                    _buildSortDropdown(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Quick stats
          BlocBuilder<JournalStatsBloc, JournalStatsState>(
            builder: (context, state) {
              if (state is JournalStatsLoaded) {
                return Padding(
                  padding: AppSpacing.paddingMD,
                  child: QuickStatsWidget(stats: state.stats),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Journal entries list
          Expanded(
            child: BlocBuilder<JournalBloc, JournalState>(
              builder: (context, state) {
                if (state is JournalLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is JournalError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: CryptoColors.error,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          state.message,
                          style: AppTypography.body1,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (state is JournalLoaded) {
                  if (state.entries.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    itemCount: state.entries.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final entry = state.entries[index];
                      return JournalEntryCard(
                        entry: entry,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/portfolio/journal/${entry.id}',
                          );
                        },
                        onEdit: () {
                          Navigator.pushNamed(
                            context,
                            '/portfolio/journal/${entry.id}/edit',
                          );
                        },
                        onDelete: () =>
                            _showDeleteConfirmation(context, entry.id),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/portfolio/journal/add');
        },
        icon: const Icon(Icons.add),
        label: const Text(_addButton),
      ),
    );
  }

  Widget _buildFilterChip(String label, JournalFilter filter) {
    final isSelected = _selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
          context.read<JournalBloc>().add(JournalFilterChanged(filter));
        },
        selectedColor: CryptoColors.primary.withValues(alpha: 0.2),
        checkmarkColor: CryptoColors.primary,
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: CryptoColors.surfaceBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: CryptoColors.borderDark),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JournalSort>(
          value: _selectedSort,
          icon: const Icon(Icons.arrow_drop_down),
          items: [
            DropdownMenuItem(
              value: JournalSort.dateDesc,
              child: Text(_sortByDate, style: AppTypography.body2),
            ),
            DropdownMenuItem(
              value: JournalSort.pnlDesc,
              child: Text(_sortByPnl, style: AppTypography.body2),
            ),
            DropdownMenuItem(
              value: JournalSort.rrDesc,
              child: Text(_sortByRR, style: AppTypography.body2),
            ),
          ],
          onChanged: (sort) {
            if (sort != null) {
              setState(() {
                _selectedSort = sort;
              });
              context.read<JournalBloc>().add(JournalSortChanged(sort));
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
            size: 80,
            color: CryptoColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _emptyStateTitle,
            style: AppTypography.h4,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _emptyStateSubtitle,
            style: AppTypography.body1.copyWith(
              color: CryptoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int entryId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(_deleteConfirmTitle),
        content: const Text(_deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(_cancelButton),
          ),
          TextButton(
            onPressed: () {
              context.read<JournalBloc>().add(JournalEntryDeleted(entryId));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: CryptoColors.error,
            ),
            child: const Text(_deleteButton),
          ),
        ],
      ),
    );
  }
}
