import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';

class Transaction {
  final String id;
  final TransactionType transactionType;
  String? categoryId;
  final DateTime date;
  final String currencyId;
  String? description;
  final List<BalanceAmount> transactedAmount;
  final String relatedAccountId;

  Transaction({
    required this.id, 
    required this.transactionType, 
    this.categoryId, 
    required this.date, 
    required this.currencyId, 
    this.description, 
    required this.transactedAmount, 
    required this.relatedAccountId
  });

  Transaction clone() {
    return Transaction(
      id: this.id, 
      transactionType: this.transactionType, 
      categoryId: this.categoryId,
      date: this.date, 
      currencyId: this.currencyId,
      description: this.description, 
      transactedAmount: this.transactedAmount, 
      relatedAccountId: this.relatedAccountId
    );
  }

  double getTotalTransacted() {
    double total = 0;
    for (BalanceAmount balanceAmount in this.transactedAmount) {
      total += balanceAmount.amount;
    }
    return total;
  }

  double getExchangedTotal() {
    double total = 0;
    for (BalanceAmount balanceAmount in this.transactedAmount) {
      total += balanceAmount.amount / balanceAmount.exchangeRate;
    }
    return total;
  }
}