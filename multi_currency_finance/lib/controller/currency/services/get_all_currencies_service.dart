import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/entities/currency_data.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/currency.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';

class GetAllCurrenciesService implements IService<GetAllCurrenciesRequest, GetAllCurrenciesResponse> {
  late final ICurrencyRepository _currencyRepository;

  GetAllCurrenciesService({required ICurrencyRepository currencyRepository}) :
    this._currencyRepository = currencyRepository;

  @override
  Future<Result<GetAllCurrenciesResponse>> execute(GetAllCurrenciesRequest params) async {
    final currenciesResult = await this._currencyRepository.findAll(params.page, params.page);

    if (currenciesResult.isError) return Result.failure(currenciesResult.error);

    final List<CurrencyData> currencyDataList = [];
    for (Currency cur in currenciesResult.value) {
      currencyDataList.add(CurrencyData(
        id: cur.id, 
        name: cur.name, 
        abbreviation: cur.abbreviation, 
        symbol: cur.symbol
      ));
    }

    return Result.success(GetAllCurrenciesResponse(currencies: currencyDataList));
  }
}

class GetAllCurrenciesRequest {
  late final int? page;
  late final int? perPage;

  GetAllCurrenciesRequest({this.page, this.perPage});
}

class GetAllCurrenciesResponse {
  late final List<CurrencyData> currencies;

  GetAllCurrenciesResponse({required this.currencies});
}
