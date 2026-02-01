// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsModelAdapter
    extends TypeAdapter<NotificationSettingsModel> {
  @override
  final int typeId = 13;

  @override
  NotificationSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettingsModel(
      priceAlerts: fields[0] as bool,
      portfolioAlerts: fields[1] as bool,
      newsAlerts: fields[2] as bool,
      marketUpdates: fields[3] as bool,
      soundEnabled: fields[4] as bool,
      vibrationEnabled: fields[5] as bool,
      fcmToken: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettingsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.priceAlerts)
      ..writeByte(1)
      ..write(obj.portfolioAlerts)
      ..writeByte(2)
      ..write(obj.newsAlerts)
      ..writeByte(3)
      ..write(obj.marketUpdates)
      ..writeByte(4)
      ..write(obj.soundEnabled)
      ..writeByte(5)
      ..write(obj.vibrationEnabled)
      ..writeByte(6)
      ..write(obj.fcmToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
