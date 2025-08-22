import 'package:hive/hive.dart';
import 'package:multi_currency_finance/model/currency/currency.dart';

part 'hive_currency_entities.g.dart';

@HiveType(typeId: 2)
class CurrencyHiveObject extends HiveObject {
  @HiveField(0)
  late final String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String abbreviation;

  @HiveField(3)
  late String symbol;

  @HiveField(4)
  late final bool isMain;

  CurrencyHiveObject({required this.id, required this.name, required this.abbreviation, required this.symbol, required this.isMain});

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