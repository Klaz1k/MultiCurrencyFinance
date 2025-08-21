// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_account_entities.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountHiveObjectAdapter extends TypeAdapter<AccountHiveObject> {
  @override
  final int typeId = 0;

  @override
  AccountHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountHiveObject(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      currencyId: fields[3] as String,
      balance: (fields[4] as List).cast<BalanceHiveObject>(),
    );
  }

  @override
  void write(BinaryWriter writer, AccountHiveObject obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.currencyId)
      ..writeByte(4)
      ..write(obj.balance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BalanceHiveObjectAdapter extends TypeAdapter<BalanceHiveObject> {
  @override
  final int typeId = 1;

  @override
  BalanceHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BalanceHiveObject(
      amount: fields[0] as double,
      exchangeRate: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BalanceHiveObject obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.exchangeRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
