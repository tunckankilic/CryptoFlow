import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'holding.dart';

/// Represents a summary of the entire portfolio
@immutable
class PortfolioSummary extends Equatable {
  /// Total current value of all holdings (in quote asset, typically USDT)
  final double totalValue;

  /// Total amount invested (cost basis)
  final double totalInvested;

  /// Total profit/loss in absolute terms
  final double totalPnl;

  /// Total profit/loss as a percentage
  final double totalPnlPercent;

  /// Portfolio value in BTC
  final double btcValue;

  /// Asset allocation map (symbol -> percentage)
  final Map<String, double> allocation;

  /// List of all holdings
  final List<Holding> holdings;

  const PortfolioSummary({
    required this.totalValue,
    required this.totalInvested,
    required this.totalPnl,
    required this.totalPnlPercent,
    required this.btcValue,
    required this.allocation,
    required this.holdings,
  });

  /// Check if portfolio is profitable
  bool get isProfit => totalPnl >= 0;

  /// Number of different assets held
  int get numberOfAssets => holdings.length;

  /// Check if portfolio is empty
  bool get isEmpty => holdings.isEmpty;

  /// Creates an empty portfolio summary
  factory PortfolioSummary.empty() {
    return const PortfolioSummary(
      totalValue: 0,
      totalInvested: 0,
      totalPnl: 0,
      totalPnlPercent: 0,
      btcValue: 0,
      allocation: {},
      holdings: [],
    );
  }

  /// Creates a copy of this PortfolioSummary with the given fields replaced
  PortfolioSummary copyWith({
    double? totalValue,
    double? totalInvested,
    double? totalPnl,
    double? totalPnlPercent,
    double? btcValue,
    Map<String, double>? allocation,
    List<Holding>? holdings,
  }) {
    return PortfolioSummary(
      totalValue: totalValue ?? this.totalValue,
      totalInvested: totalInvested ?? this.totalInvested,
      totalPnl: totalPnl ?? this.totalPnl,
      totalPnlPercent: totalPnlPercent ?? this.totalPnlPercent,
      btcValue: btcValue ?? this.btcValue,
      allocation: allocation ?? this.allocation,
      holdings: holdings ?? this.holdings,
    );
  }

  @override
  List<Object?> get props => [
        totalValue,
        totalInvested,
        totalPnl,
        totalPnlPercent,
        btcValue,
        allocation,
        holdings,
      ];
}
