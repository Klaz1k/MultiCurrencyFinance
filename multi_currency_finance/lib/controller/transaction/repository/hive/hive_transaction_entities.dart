// ignore_for_file: constant_identifier_names

import 'package:hive/hive.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_entities.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

part 'hive_transaction_entities.g.dart';


@HiveType(typeId: 3)
class TransactionHiveObject extends HiveObject {
  @HiveField(0)
  late final String id;

  @HiveField(1)
  late final TransactionTypeHiveObject transactionType;

  @HiveField(2)
  late final String? categoryId;

  @HiveField(3)
  late final DateTime date;

  @HiveField(4)
  late final String currencyId;

  @HiveField(5)
  late String? description;

  @HiveField(6)
  late final List<BalanceHiveObject> transactedAmount;

  @HiveField(7)
  late final String relatedAccountId;

  TransactionHiveObject({
    required this.id,
    required this.transactionType,
    this.categoryId,
    required this.date,
    required this.currencyId,
    this.description,
    required this.transactedAmount,
    required this.relatedAccountId
  });

  Transaction toDomain() {
    return Transaction(
      id: this.id, 
      transactionType: TransactionType.values.firstWhere((type) => type.name == this.transactionType.name),
      description: this.description, 
      date: this.date, 
      currencyId: this.currencyId, 
      transactedAmount: this.transactedAmount.map((subBalance) => subBalance.toDomain()).toList(), 
      relatedAccountId: this.relatedAccountId
    );
  }
}

@HiveType(typeId: 4)
enum TransactionTypeHiveObject {
  @HiveField(0)
  Deposit,

  @HiveField(1)
  Withdrawal,

  @HiveField(2)
  IncomingTransfer,

  @HiveField(3)
  OutgoingTransfer
}

