import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/common/uuid/uuid_generator.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/currency.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';

class CreateCurrencyService implements IService<CreateCurrencyRequest, CreateCurrencyResponse> {
  late final ICurrencyRepository _currencyRepository;

  CreateCurrencyService(this._currencyRepository);

  @override
  Future<Result<CreateCurrencyResponse>> execute(CreateCurrencyRequest params) async {
    final uuidGenerator = UuidGenerator.instance;

    final Currency newCurrency = Currency(
      uuidGenerator.v4(),
      params.currencyName,
      params.currencyAbbreviation,
      params.currencySymbol
    );

    final saveResult = await this._currencyRepository.save(newCurrency);

    if (saveResult.isError) return Result.failure(saveResult.error);

    return Result.success(CreateCurrencyResponse(newCurrency.id));
  }
}

class CreateCurrencyRequest {
  late final String _currencyName;
  late final String _currencyAbbreviation;
  late final String _currencySymbol;

  String get currencyName => this._currencyName;
  String get currencyAbbreviation => this._currencyAbbreviation;
  String get currencySymbol => this._currencySymbol;

  CreateCurrencyRequest(this._currencyName, this._currencyAbbreviation, this._currencySymbol);
}

class CreateCurrencyResponse {
  late final String _currencyId;

  String get currencyId => this._currencyId;

  CreateCurrencyResponse(this._currencyId);
}