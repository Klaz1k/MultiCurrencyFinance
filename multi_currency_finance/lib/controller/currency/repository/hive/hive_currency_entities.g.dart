// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_currency_entities.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyHiveObjectAdapter extends TypeAdapter<CurrencyHiveObject> {
  @override
  final int typeId = 2;

  @override
  CurrencyHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyHiveObject(
      id: fields[0] as String,
      name: fields[1] as String,
      abbreviation: fields[2] as String,
      symbol: fields[3] as String,
      isMain: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyHiveObject obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.abbreviation)
      ..writeByte(3)
      ..write(obj.symbol)
      ..writeByte(4)
      ..write(obj.isMain);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
