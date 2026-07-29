import 'package:json_annotation/json_annotation.dart';
import 'package:multi_currency_finance/model/currency/currency.dart';

part 'currency_json.g.dart';

@JsonSerializable()
class CurrencyJson {
  late final String id;
  late String name;
  late String abbreviation;
  late String symbol;
  late final bool isMain;

  CurrencyJson({required this.id, required this.name, required this.abbreviation, required this.symbol, required this.isMain});

  factory CurrencyJson.fromJson(Map<String, dynamic> json) => _$CurrencyJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyJsonToJson(this);

  factory CurrencyJson.fromDomain(Currency currency) {
    return CurrencyJson(
      id: currency.id, 
      name: currency.name, 
      abbreviation: currency.abbreviation, 
      symbol: currency.symbol, 
      isMain: currency.isMain
    );
  }

  Currency toDomain() {
    return Currency(
      id: this.id, 
      name: this.name, 
      abbreviation: this.abbreviation, 
      symbol: this.symbol, 
      isMain: this.isMain
    );
  }
}