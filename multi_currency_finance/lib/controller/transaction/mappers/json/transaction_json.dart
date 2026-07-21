import 'package:json_annotation/json_annotation.dart';
import 'package:multi_currency_finance/controller/account/mappers/json/account_json.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

part 'transaction_json.g.dart';

@JsonSerializable()
class TransactionJson {
  late final String id;
  late final TransactionType transactionType;
  late final String? categoryId;
  late final DateTime date;
  late final String currencyId;
  late final String? description;
  late final List<BalanceAmountJson> transactedAmount;
  late final String relatedAccountId;

  TransactionJson({
    required this.id, 
    required this.transactionType, 
    this.categoryId, 
    required this.date, 
    required this.currencyId, 
    this.description, 
    required this.transactedAmount, 
    required this.relatedAccountId
  });

  factory TransactionJson.fromJson(Map<String, dynamic> json) => _$TransactionJsonFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionJsonToJson(this);

  factory TransactionJson.fromDomain(Transaction transaction) {
    return TransactionJson(
      id: transaction.id, 
      transactionType: transaction.transactionType, 
      date: transaction.date, 
      currencyId: transaction.currencyId, 
      transactedAmount: transaction.transactedAmount.map((balanceAmount) => BalanceAmountJson.fromDomain(balanceAmount)).toList(), 
      relatedAccountId: transaction.relatedAccountId
    );
  }

  Transaction toDomain() {
    return Transaction(
      id: this.id, 
      transactionType: this.transactionType, 
      date: this.date, 
      currencyId: this.currencyId, 
      transactedAmount: this.transactedAmount.map((balanceAmount) => balanceAmount.toDomain()).toList(), 
      relatedAccountId: this.relatedAccountId
    );
  }
}