import 'package:hive/hive.dart';
import '../../domain/entities/watchlist_item.dart';

part 'watchlist_item_model.g.dart';

/// Data model for WatchlistItem with Hive storage
@HiveType(typeId: 2)
class WatchlistItemModel extends WatchlistItem {
  @HiveField(0)
  final String hiveSymbol;

  @HiveField(1)
  final int hiveOrder;

  @HiveField(2)
  final int hiveAddedAt;

  WatchlistItemModel({
    required this.hiveSymbol,
    required this.hiveOrder,
    required this.hiveAddedAt,
  }) : super(
          symbol: hiveSymbol,
          order: hiveOrder,
          addedAt: DateTime.fromMillisecondsSinceEpoch(hiveAddedAt),
        );

  /// Create from domain entity
  factory WatchlistItemModel.fromEntity(WatchlistItem item) {
    return WatchlistItemModel(
      hiveSymbol: item.symbol,
      hiveOrder: item.order,
      hiveAddedAt: item.addedAt.millisecondsSinceEpoch,
    );
  }

  /// Convert to domain entity
  WatchlistItem toEntity() {
    return WatchlistItem(
      symbol: hiveSymbol,
      order: hiveOrder,
      addedAt: DateTime.fromMillisecondsSinceEpoch(hiveAddedAt),
    );
  }
}
