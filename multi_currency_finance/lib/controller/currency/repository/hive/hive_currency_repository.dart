import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/currency.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';

class HiveCurrencyRepository implements ICurrencyRepository {
  static final HiveCurrencyRepository instance = HiveCurrencyRepository._();

  HiveCurrencyRepository._();
  final String dbName = 'currency';
  
  @override
  Future<Result<List<Currency>>> findAll(int? page, int? perPage) {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  Future<Result<Currency>> findById(String id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  Future<Result<Currency>> findMainCurrency() {
    // TODO: implement findMainCurrency
    throw UnimplementedError();
  }

  @override
  Future<Result<String>> save(Currency entity) {
    // TODO: implement save
    throw UnimplementedError();
  }

}