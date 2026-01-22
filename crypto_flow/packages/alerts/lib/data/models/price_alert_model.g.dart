// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_alert_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceAlertModelAdapter extends TypeAdapter<PriceAlertModel> {
  @override
  final int typeId = 1;

  @override
  PriceAlertModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceAlertModel(
      hiveId: fields[0] as String,
      hiveSymbol: fields[1] as String,
      hiveType: fields[2] as String,
      hiveTargetPrice: fields[3] as double,
      hivePercentChange: fields[4] as double?,
      hiveBasePrice: fields[5] as double?,
      hiveIsActive: fields[6] as bool,
      hiveIsTriggered: fields[7] as bool,
      hiveCreatedAt: fields[8] as int,
      hiveTriggeredAt: fields[9] as int?,
      hiveRepeatEnabled: fields[10] as bool,
      hiveNote: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PriceAlertModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.hiveId)
      ..writeByte(1)
      ..write(obj.hiveSymbol)
      ..writeByte(2)
      ..write(obj.hiveType)
      ..writeByte(3)
      ..write(obj.hiveTargetPrice)
      ..writeByte(4)
      ..write(obj.hivePercentChange)
      ..writeByte(5)
      ..write(obj.hiveBasePrice)
      ..writeByte(6)
      ..write(obj.hiveIsActive)
      ..writeByte(7)
      ..write(obj.hiveIsTriggered)
      ..writeByte(8)
      ..write(obj.hiveCreatedAt)
      ..writeByte(9)
      ..write(obj.hiveTriggeredAt)
      ..writeByte(10)
      ..write(obj.hiveRepeatEnabled)
      ..writeByte(11)
      ..write(obj.hiveNote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceAlertModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
