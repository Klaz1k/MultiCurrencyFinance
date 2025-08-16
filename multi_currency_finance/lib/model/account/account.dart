import 'package:multi_currency_finance/model/account/entities/balance.dart';
import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';

class Account {
  late final String id;
  late String name;
  late String? description;
  late final String currencyId;
  late final Balance _balance;

  Balance get balance => Balance(balanceQueue: this._balance.balanceQueue);

  Account({required this.id, required this.name, this.description, required this.currencyId, required Balance balance}) :
    this._balance = balance;

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