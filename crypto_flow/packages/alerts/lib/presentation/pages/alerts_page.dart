import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';
import '../widgets/alert_tile.dart';
import '../widgets/create_alert_sheet.dart';
import 'package:design_system/design_system.dart';

/// Page showing all price alerts
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
      ),
      body: BlocBuilder<AlertBloc, AlertState>(
        builder: (context, state) {
          if (state is AlertLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AlertError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading alerts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AlertBloc>().add(const LoadAlerts());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AlertLoaded) {
            if (state.alerts.isEmpty) {
              return _buildEmptyState(context);
            }

            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'All (${state.alerts.length})'),
                      Tab(text: 'Active (${state.activeAlerts.length})'),
                      Tab(text: 'Triggered (${state.triggeredAlerts.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildAlertList(context, state.alerts),
                        _buildAlertList(context, state.activeAlerts),
                        _buildAlertList(context, state.triggeredAlerts),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateAlertSheet(context);
        },
        child: const Icon(Icons.add_alert),
      ),
    );
  }

  Widget _buildAlertList(BuildContext context, List alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No alerts in this category',
              style: AppTypography.h5,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.paddingMD,
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Dismissible(
          key: Key(alert.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: AppSpacing.paddingMD,
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Alert'),
                content:
                    const Text('Are you sure you want to delete this alert?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            context.read<AlertBloc>().add(DeleteAlertEvent(alert.id));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Alert deleted')),
            );
          },
          child: AlertTile(alert: alert),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            'No alerts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Create your first price alert'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateAlertSheet(context),
            icon: const Icon(Icons.add_alert),
            label: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  void _showCreateAlertSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<AlertBloc>(),
        child: const CreateAlertSheet(),
      ),
    );
  }
}
