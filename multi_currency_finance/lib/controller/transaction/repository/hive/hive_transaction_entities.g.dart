// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_transaction_entities.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionHiveObjectAdapter extends TypeAdapter<TransactionHiveObject> {
  @override
  final int typeId = 3;

  @override
  TransactionHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionHiveObject(
      id: fields[0] as String,
      transactionType: fields[1] as TransactionTypeHiveObject,
      categoryId: fields[2] as String?,
      date: fields[3] as DateTime,
      currencyId: fields[4] as String,
      description: fields[5] as String?,
      transactedAmount: (fields[6] as List).cast<BalanceHiveObject>(),
      relatedAccountId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionHiveObject obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transactionType)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.currencyId)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.transactedAmount)
      ..writeByte(7)
      ..write(obj.relatedAccountId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeHiveObjectAdapter
    extends TypeAdapter<TransactionTypeHiveObject> {
  @override
  final int typeId = 4;

  @override
  TransactionTypeHiveObject read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionTypeHiveObject.Deposit;
      case 1:
        return TransactionTypeHiveObject.Withdrawal;
      case 2:
        return TransactionTypeHiveObject.IncomingTransfer;
      case 3:
        return TransactionTypeHiveObject.OutgoingTransfer;
      default:
        return TransactionTypeHiveObject.Deposit;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionTypeHiveObject obj) {
    switch (obj) {
      case TransactionTypeHiveObject.Deposit:
        writer.writeByte(0);
        break;
      case TransactionTypeHiveObject.Withdrawal:
        writer.writeByte(1);
        break;
      case TransactionTypeHiveObject.IncomingTransfer:
        writer.writeByte(2);
        break;
      case TransactionTypeHiveObject.OutgoingTransfer:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
