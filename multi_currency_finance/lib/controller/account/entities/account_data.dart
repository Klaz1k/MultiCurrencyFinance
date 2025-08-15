import 'package:multi_currency_finance/model/account/entities/balance.dart';

class AccountData {
  late final String id;
  late final String name;
  late final String? description;
  late final String currencySymbol;
  late final Balance balance;

  AccountData(this.id, this.name, this.description, this.currencySymbol, this.balance);
}