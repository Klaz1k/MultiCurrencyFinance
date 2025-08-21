import 'package:hive/hive.dart';
import 'package:multi_currency_finance/model/account/account.dart';
import 'package:multi_currency_finance/model/account/entities/balance.dart';
import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';

part 'hive_account_entities.g.dart';

@HiveType(typeId: 0)
class AccountHiveObject extends HiveObject {
  @HiveField(0)
  late final String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String? description;

  @HiveField(3)
  late final String currencyId;

  @HiveField(4)
  late final List<BalanceHiveObject> balance;

  AccountHiveObject({required this.id, required this.name, this.description, required this.currencyId, required this.balance});

  Account toDomain() {
    return Account(
      id: this.id,
      name: this.name,
      description: this.description,
      currencyId: this.currencyId,
      balance: Balance(balanceQueue: this.balance.map((subBalance) => subBalance.toDomain()).toList())
    );
  }
}

@HiveType(typeId: 1)
class BalanceHiveObject {
  @HiveField(0)
  late double amount;

  @HiveField(1)
  late final double exchangeRate;

  BalanceHiveObject({required this.amount, required this.exchangeRate});

  BalanceAmount toDomain() {
    return BalanceAmount(
      amount: this.amount,
      exchangeRate: this.exchangeRate
    );
  }
}