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

    final saveResult = await this._currencyRepository.save(
      Currency(
        uuidGenerator.v4(),
        params.currencyName,
        params.currencyAbbreviation,
        params.currencySymbol
      )
    );

    if (saveResult.isError) return Result.failure(saveResult.error);

    return Result.success(CreateCurrencyResponse(saveResult.value));
  }
}

class CreateCurrencyRequest {
  late final String currencyName;
  late final String currencyAbbreviation;
  late final String currencySymbol;

  CreateCurrencyRequest(this.currencyName, this.currencyAbbreviation, this.currencySymbol);
}

class CreateCurrencyResponse {
  late final String currencyId;

  CreateCurrencyResponse(this.currencyId);
}