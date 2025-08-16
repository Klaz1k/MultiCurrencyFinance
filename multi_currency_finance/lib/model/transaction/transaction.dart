import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';

class Transaction {
  late final String id;
  late final TransactionType transactionType;
  late final String? categoryId; //TODO: Right now this will never be !null, transaction category module is coming after initial release
  late final DateTime date;
  late final String currencyId;
  late final String? description;
  late final BalanceAmount transactedAmount;
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
}