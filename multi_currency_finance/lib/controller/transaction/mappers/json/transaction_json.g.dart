// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionJson _$TransactionJsonFromJson(Map<String, dynamic> json) =>
    TransactionJson(
      id: json['id'] as String,
      transactionType:
          $enumDecode(_$TransactionTypeEnumMap, json['transactionType']),
      categoryId: json['categoryId'] as String?,
      date: DateTime.parse(json['date'] as String),
      currencyId: json['currencyId'] as String,
      description: json['description'] as String?,
      transactedAmount: (json['transactedAmount'] as List<dynamic>)
          .map((e) => BalanceAmountJson.fromJson(e as Map<String, dynamic>))
          .toList(),
      relatedAccountId: json['relatedAccountId'] as String,
    );

Map<String, dynamic> _$TransactionJsonToJson(TransactionJson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionType': _$TransactionTypeEnumMap[instance.transactionType]!,
      'categoryId': instance.categoryId,
      'date': instance.date.toIso8601String(),
      'currencyId': instance.currencyId,
      'description': instance.description,
      'transactedAmount': instance.transactedAmount,
      'relatedAccountId': instance.relatedAccountId,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.Deposit: 'Deposit',
  TransactionType.Withdrawal: 'Withdrawal',
  TransactionType.IncomingTransfer: 'IncomingTransfer',
  TransactionType.OutgoingTransfer: 'OutgoingTransfer',
};
