// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountJson _$AccountJsonFromJson(Map<String, dynamic> json) => AccountJson(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      currencyId: json['currencyId'] as String,
      balance: (json['balance'] as List<dynamic>)
          .map((e) => BalanceAmountJson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AccountJsonToJson(AccountJson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'currencyId': instance.currencyId,
      'balance': instance.balance,
    };

BalanceAmountJson _$BalanceAmountJsonFromJson(Map<String, dynamic> json) =>
    BalanceAmountJson(
      amount: (json['amount'] as num).toDouble(),
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
    );

Map<String, dynamic> _$BalanceAmountJsonToJson(BalanceAmountJson instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'exchangeRate': instance.exchangeRate,
    };
