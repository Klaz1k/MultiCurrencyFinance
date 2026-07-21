// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyJson _$CurrencyJsonFromJson(Map<String, dynamic> json) => CurrencyJson(
      id: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      symbol: json['symbol'] as String,
      isMain: json['isMain'] as bool,
    );

Map<String, dynamic> _$CurrencyJsonToJson(CurrencyJson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'abbreviation': instance.abbreviation,
      'symbol': instance.symbol,
      'isMain': instance.isMain,
    };
