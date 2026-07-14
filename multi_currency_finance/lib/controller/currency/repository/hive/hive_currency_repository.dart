import 'package:hive/hive.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_entities.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/currency.dart';
import 'package:multi_currency_finance/model/currency/errors/currency_not_found_error.dart';
import 'package:multi_currency_finance/model/currency/errors/main_currency_not_found_error.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';

class HiveCurrencyRepository implements ICurrencyRepository {
  static final HiveCurrencyRepository instance = HiveCurrencyRepository._();

  HiveCurrencyRepository._();
  final String dbName = 'currencies';
  
  @override
  Future<Result<List<Currency>>> findAll(int? page, int? perPage) async {
    final box = await Hive.openBox<CurrencyHiveObject>(dbName);
    final List<Currency> currencies = [];

    if (page == null || perPage == null) {
      for (final hiveCurrency in box.values) {
        currencies.add(hiveCurrency.toDomain());
      }
      return Result.success(currencies);
    }

    for (final hiveCurrency in box.values.skip(page*perPage).take(perPage)) {
      currencies.add(hiveCurrency.toDomain());
    }

    return Result.success(currencies);
  }

  @override
  Future<Result<Currency>> findById(String id) async {
    final box = await Hive.openBox<CurrencyHiveObject>(dbName);

    if (!box.containsKey(id)) return Result.failure(CurrencyNotFoundError());

    return Result.success(box.get(id)!.toDomain());
  }

  @override
  Future<Result<Currency>> findMainCurrency() async {
    final box = await Hive.openBox<CurrencyHiveObject>(dbName);
    try {
      final mainCurrency = box.values.firstWhere((hiveCur) => hiveCur.isMain);

      return Result.success(mainCurrency.toDomain());
    } catch (e) {
      return Result.failure(MainCurrencyNotFoundError());
    }
  }

  @override
  Future<Result<String>> save(Currency currency) async {
    final box = await Hive.openBox<CurrencyHiveObject>(dbName);

    await box.put(
      currency.id, 
      CurrencyHiveObject(
        id: currency.id, 
        name: currency.name, 
        abbreviation: currency.abbreviation, 
        symbol: currency.symbol, 
        isMain: currency.isMain
      )
    );

    return Result.success(currency.id);
  }
  
  @override
  Future<Result<String>> delete(String id) async {
    final box = await Hive.openBox<CurrencyHiveObject>(dbName);

    if (!box.containsKey(id)) return Result.failure(CurrencyNotFoundError());

    await box.delete(id);

    return Result.success(id);
  }

}