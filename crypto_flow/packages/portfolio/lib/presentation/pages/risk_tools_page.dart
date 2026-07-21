import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import '../bloc/risk/risk_bloc.dart';
import '../widgets/risk/position_size_calculator.dart';
import '../widgets/risk/correlation_heatmap.dart';
import '../widgets/risk/var_display.dart';

/// Risk tools page with position size calculator, correlation matrix, and VaR
class RiskToolsPage extends StatefulWidget {
  const RiskToolsPage({super.key});

  @override
  State<RiskToolsPage> createState() => _RiskToolsPageState();
}

class _RiskToolsPageState extends State<RiskToolsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
        title: const Text('Risk Tools'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Position Size'),
            Tab(text: 'Correlation'),
            Tab(text: 'VaR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PositionSizeTab(),
          _CorrelationTab(),
          _VaRTab(),
        ],
      ),
    );
  }
}

class _PositionSizeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiskBloc, RiskState>(
      builder: (context, state) {
        final result = state is PositionSizeLoaded ? state.result : null;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PositionSizeCalculator(
            result: result,
            onCalculate: (params) {
              context.read<RiskBloc>().add(PositionSizeRequested(
                    symbol: params['symbol'] ?? '',
                    accountSize:
                        double.tryParse(params['accountSize'] ?? '') ?? 0,
                    riskPercentage:
                        double.tryParse(params['riskPercentage'] ?? '') ?? 1,
                    entryPrice:
                        double.tryParse(params['entryPrice'] ?? '') ?? 0,
                    stopLossPrice:
                        double.tryParse(params['stopLossPrice'] ?? '') ?? 0,
                  ));
            },
          ),
        );
      },
    );
  }
}

class _CorrelationTab extends StatefulWidget {
  @override
  State<_CorrelationTab> createState() => _CorrelationTabState();
}

class _CorrelationTabState extends State<_CorrelationTab> {
  @override
  void initState() {
    super.initState();
    context.read<RiskBloc>().add(const CorrelationRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiskBloc, RiskState>(
      builder: (context, state) {
        if (state is RiskLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CorrelationLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: CorrelationHeatmap(matrix: state.matrix),
          );
        }
        if (state is RiskError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _VaRTab extends StatefulWidget {
  @override
  State<_VaRTab> createState() => _VaRTabState();
}

class _VaRTabState extends State<_VaRTab> {
  @override
  void initState() {
    super.initState();
    context.read<RiskBloc>().add(const VaRRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiskBloc, RiskState>(
      builder: (context, state) {
        if (state is RiskLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is VaRLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: VaRDisplay(result: state.result),
          );
        }
        if (state is RiskError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
