import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import '../bloc/fear_greed/fear_greed_bloc.dart';
import '../bloc/fear_greed/fear_greed_event.dart';
import '../bloc/fear_greed/fear_greed_state.dart';

/// Widget displaying the Crypto Fear & Greed Index
class FearGreedCard extends StatelessWidget {
  const FearGreedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FearGreedBloc, FearGreedState>(
      builder: (context, state) {
        if (state is FearGreedInitial) {
          context.read<FearGreedBloc>().add(const LoadFearGreedIndex());
          return const SizedBox.shrink();
        }

        if (state is FearGreedLoading) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(24),
              height: 200,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is FearGreedError) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<FearGreedBloc>()
                          .add(const LoadFearGreedIndex());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is FearGreedLoaded) {
          final index = state.index;
          final timeSinceUpdate = DateTime.now().difference(index.timestamp);
          final hoursAgo = timeSinceUpdate.inHours;

          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Market Sentiment',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        index.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crypto Fear & Greed Index',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GaugeWidget(
                      value: index.value,
                      label: index.classification,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      hoursAgo == 0
                          ? 'Updated just now'
                          : 'Updated ${hoursAgo}h ago',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
