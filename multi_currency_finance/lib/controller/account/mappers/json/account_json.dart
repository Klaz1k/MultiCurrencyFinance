import 'package:json_annotation/json_annotation.dart';
import 'package:multi_currency_finance/model/account/account.dart';
import 'package:multi_currency_finance/model/account/entities/balance.dart';
import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';

part 'account_json.g.dart';

@JsonSerializable()
class AccountJson {
  late final String id;
  late String name;
  late String? description;
  late final String currencyId;
  late final List<BalanceAmountJson> balance;


  AccountJson({required this.id, required this.name, this.description, required this.currencyId, required this.balance});

  factory AccountJson.fromJson(Map<String, dynamic> json) => _$AccountJsonFromJson(json);

  Map<String, dynamic> toJson() => _$AccountJsonToJson(this);

  factory AccountJson.fromDomain(Account account) {
    return AccountJson(
      id: account.id, 
      name: account.name, 
      currencyId: account.currencyId, 
      balance: account.balance.balanceQueue.map((balanceAmount) => BalanceAmountJson.fromDomain(balanceAmount)).toList()
    );
  }

  Account toDomain() {
    return Account(
      id: this.id, 
      name: this.name, 
      currencyId: this.currencyId, 
      balance: Balance(balanceQueue: this.balance.map((balanceAmount) => balanceAmount.toDomain()).toList())
    );
  }
}

@JsonSerializable()
class BalanceAmountJson {
  late double amount;
  late final double exchangeRate;

  BalanceAmountJson({required this.amount, required this.exchangeRate});

  factory BalanceAmountJson.fromJson(Map<String, dynamic> json) => _$BalanceAmountJsonFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceAmountJsonToJson(this);

  factory BalanceAmountJson.fromDomain(BalanceAmount balanceAmount) {
    return BalanceAmountJson(amount: balanceAmount.amount, exchangeRate: balanceAmount.exchangeRate);
  }

  BalanceAmount toDomain() {
    return BalanceAmount(amount: this.amount, exchangeRate: this.exchangeRate);
  }
}