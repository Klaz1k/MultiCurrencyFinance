import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';

class TransactionData {
  late final TransactionType type;
  late final DateTime date;
  late final String currencySymbol;
  late final String? description;
  late final List<BalanceAmount> balanceList;
  late final double totalAmount;
  late final double exchangedTotal;
  late final String relatedAccountName;

  TransactionData({
    required this.type,
    required this.date,
    required this.currencySymbol,
    this.description,
    required this.balanceList,
    required this.totalAmount,
    required this.exchangedTotal,
    required this.relatedAccountName
  });
}