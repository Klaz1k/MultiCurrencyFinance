import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';

class Transaction {
  late final String id;
  late final TransactionType transactionType;
  late final String? categoryId; //TODO: Right now this will never be !null, transaction category module is coming after initial release
  late final DateTime date;
  late final String currencyId;
  late final String? description;
  late final List<BalanceAmount> transactedAmount;
  late final String relatedAccountId;

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
      date: this.date, 
      currencyId: this.currencyId, 
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