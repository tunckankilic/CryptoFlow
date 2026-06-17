import 'package:core/core.dart';

import '../../domain/entities/holding.dart';
import '../../domain/entities/transaction.dart';
import '../models/holding_model.dart';
import '../models/transaction_model.dart';

/// Remote data source for portfolio operations against the AWS backend.
abstract class PortfolioRemoteDataSource {
  Future<List<Holding>> getHoldings();
  Future<Holding> createHolding(Holding holding);
  Future<Holding> updateHolding(String holdingId, Holding holding);
  Future<void> deleteHolding(String holdingId);

  Future<List<Transaction>> getTransactions();
  Future<Transaction> createTransaction(Transaction transaction);
}

/// Implementation backed by the CryptoFlow REST API.
class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  final AwsApiClient _api;
  PortfolioRemoteDataSourceImpl({required AwsApiClient apiClient})
      : _api = apiClient;

  // ---------------------------------------------------------------- Holdings

  @override
  Future<List<Holding>> getHoldings() async {
    final response = await _api.get(AwsEndpoints.holdings);
    final list = response.data as List<dynamic>;
    return list
        .map((json) => HoldingModel.fromJson(json as Map<String, dynamic>))
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<Holding> createHolding(Holding holding) async {
    final body = HoldingModel.fromEntity(holding).toJson();
    final response = await _api.post(AwsEndpoints.holdings, data: body);
    return HoldingModel.fromJson(response.data as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<Holding> updateHolding(String holdingId, Holding holding) async {
    final body = HoldingModel.fromEntity(holding).toJson();
    final response = await _api.put(
      AwsEndpoints.holding(holdingId),
      data: body,
    );
    return HoldingModel.fromJson(response.data as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<void> deleteHolding(String holdingId) async {
    await _api.delete(AwsEndpoints.holding(holdingId));
  }

  // ------------------------------------------------------------- Transactions

  @override
  Future<List<Transaction>> getTransactions() async {
    final response = await _api.get(AwsEndpoints.transactions);
    final list = response.data as List<dynamic>;
    return list
        .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    final body = TransactionModel.fromEntity(transaction).toJson();
    final response = await _api.post(AwsEndpoints.transactions, data: body);
    return TransactionModel.fromJson(response.data as Map<String, dynamic>)
        .toEntity();
  }
}
