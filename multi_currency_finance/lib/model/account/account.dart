import 'package:multi_currency_finance/model/account/entities/balance.dart';
import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';

class Account {
  late final String _id;
  late String _name;
  late String? _description;
  late final String _currencyId;
  late final Balance _balance;

  String get id => this._id;

  String get name => this._name;
  set name(String value) => this._name = value;

  String? get description => this._description;
  set description(String? value) => this._description = value;

  String get currencyId => this._currencyId;

  Balance get balance => Balance(this._balance.balanceQueue);

  Account(this._id, this._name, this._description, this._currencyId, this._balance);

  List<BalanceAmount> withdraw(double amount) {
    return this._balance.reduce(amount);
  }

  double deposit(BalanceAmount amount) {
    return this._balance.add(amount);
  }

  double getTotalBalance() {
    return this._balance.getCurrentBalance();
  }
}