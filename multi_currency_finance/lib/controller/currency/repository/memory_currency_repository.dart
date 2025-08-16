import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/currency.dart';
import 'package:multi_currency_finance/model/currency/errors/currency_not_found_error.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';

class MemoryCurrencyRepository implements ICurrencyRepository {
  // List<Currency> currencyList = [];
  List<Currency> currencyList = [Currency(id: "1", name: "TestCurrency", abbreviation: "Tst", symbol: "<>")];
  
  @override
  Future<Result<List<Currency>>> findAll(int? page, int? perPage) async {
    if (page == null || perPage == null) return Result.success(this.currencyList); 

    int start = (page)*perPage;
    int end = start + perPage;

    if (end >= this.currencyList.length) end = this.currencyList.length;

    return Result.success(this.currencyList.getRange(start, end).toList());
  }

  @override
  Future<Result<Currency>> findById(String id) async {
    for (Currency cur in this.currencyList) {
      if (cur.id == id) {
        return Result.success(cur);
      }
    }

    return Result.failure(CurrencyNotFoundError());
  }

  @override
  Future<Result<String>> save(Currency currency) async {
    for (Currency cur in this.currencyList) {
      if (cur.id == currency.id) {

        return Result.success(cur.id);
      }
    }
    this.currencyList.add(currency);
    return Result.success(currency.id);
  }
}