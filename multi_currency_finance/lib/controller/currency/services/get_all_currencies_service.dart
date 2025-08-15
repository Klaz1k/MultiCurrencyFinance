import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/entities/currency_data.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/currency.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';

class GetAllCurrenciesService implements IService<GetAllCurrenciesRequest, GetAllCurrenciesResponse> {
  late final ICurrencyRepository _currencyRepository;

  GetAllCurrenciesService(this._currencyRepository);

  @override
  Future<Result<GetAllCurrenciesResponse>> execute(GetAllCurrenciesRequest params) async {
    final currenciesResult = await this._currencyRepository.findAll(params.page, params.page);

    if (currenciesResult.isError) return Result.failure(currenciesResult.error);

    final List<CurrencyData> currencyDataList = [];
    for (Currency cur in currenciesResult.value) {
      currencyDataList.add(CurrencyData(cur.id, cur.name, cur.abbreviation, cur.symbol));
    }

    return Result.success(GetAllCurrenciesResponse(currencyDataList));
  }
}

class GetAllCurrenciesRequest {
  late final int? page;
  late final int? perPage;

  GetAllCurrenciesRequest.pag(this.page, this.perPage);

  GetAllCurrenciesRequest();
}

class GetAllCurrenciesResponse {
  late final List<CurrencyData> currencies;

  GetAllCurrenciesResponse(this.currencies);
}
