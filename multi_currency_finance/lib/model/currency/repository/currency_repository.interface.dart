import 'package:multi_currency_finance/model/common/repository/repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/currency.dart';

abstract interface class ICurrencyRepository implements IRepository<Currency> {
  Future<Result<Currency>> findMainCurrency();
}