import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';

class TransactionData {
  final String id;
  final TransactionType type;
  final DateTime date;
  final String currencySymbol;
  final String? description;
  final String? categoryId;
  final List<BalanceAmount> balanceList;
  final double totalAmount;
  final double exchangedTotal;
  final String relatedAccountName;

  TransactionData({
    required this.id,
    required this.type,
    required this.date,
    required this.currencySymbol,
    this.description,
    this.categoryId,
    required this.balanceList,
    required this.totalAmount,
    required this.exchangedTotal,
    required this.relatedAccountName
  });
}