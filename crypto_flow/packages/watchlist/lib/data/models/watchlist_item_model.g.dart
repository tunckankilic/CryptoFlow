// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchlistItemModelAdapter extends TypeAdapter<WatchlistItemModel> {
  @override
  final int typeId = 2;

  @override
  WatchlistItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchlistItemModel(
      hiveSymbol: fields[0] as String,
      hiveOrder: fields[1] as int,
      hiveAddedAt: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WatchlistItemModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.hiveSymbol)
      ..writeByte(1)
      ..write(obj.hiveOrder)
      ..writeByte(2)
      ..write(obj.hiveAddedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchlistItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
