import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ticker_list/ticker_list_bloc.dart';
import '../bloc/ticker_list/ticker_list_event.dart';
import '../bloc/ticker_list/ticker_list_state.dart';
import '../widgets/ticker_list_tile.dart';

/// Search page for finding tickers
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus on search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: 'Search symbols...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            context.read<TickerListBloc>().add(SearchTickers(query));
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<TickerListBloc>().add(const ClearSearch());
              },
            ),
        ],
      ),
      body: BlocBuilder<TickerListBloc, TickerListState>(
        builder: (context, state) {
          if (state is TickerListLoaded) {
            if (state.searchQuery == null || state.searchQuery!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Enter a symbol to search'),
                  ],
                ),
              );
            }

            if (state.filteredTickers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('No results for "${state.searchQuery}"'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: state.filteredTickers.length,
              itemBuilder: (context, index) {
                final ticker = state.filteredTickers[index];
                return TickerListTile(
                  ticker: ticker,
                  onTap: () {
                    Navigator.pop(context, ticker.symbol);
                  },
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
