import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';

class ByCategoryTransactionData {
  final String id;
  final TransactionType type;
  final String? description;
  final List<BalanceAmount> balanceList;
  final double totalAmount;
  final double exchangedTotal;

  ByCategoryTransactionData({
    required this.id,
    required this.type,
    this.description,
    required this.balanceList,
    required this.totalAmount,
    required this.exchangedTotal
  });
}