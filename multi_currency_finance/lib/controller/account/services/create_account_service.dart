import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/common/uuid/uuid_generator.dart';
import 'package:multi_currency_finance/model/account/account.dart';
import 'package:multi_currency_finance/model/account/entities/balance.dart';
import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';

class CreateAccountService implements IService<CreateAccountRequest, CreateAccountResponse> {
  late final IAccountRepository _accountRepository;
  late final ICurrencyRepository _currencyRepository;

  CreateAccountService(this._accountRepository, this._currencyRepository);

  @override
  Future<Result<CreateAccountResponse>> execute(CreateAccountRequest params) async {
    final currencyResult = await this._currencyRepository.findById(params._currencyId);

    if (currencyResult.isError) return Result.failure(currencyResult.error);
    
    final uuidGenerator = UuidGenerator.instance;

    final saveResult = await this._accountRepository.save(
      Account(
        uuidGenerator.v4(),
        params.accountName,
        params.description,
        currencyResult.value.id,
        Balance([BalanceAmount(params.amount, params.exchangeRate)])
      )
    );

    if (saveResult.isError) return Result.failure(saveResult.error);

    return Result.success(CreateAccountResponse(saveResult.value));
  }

}

class CreateAccountRequest {
  late final String _accountName;
  late final String _currencyId;
  late final String? _description;
  late final double _amount;
  late final double _exchangeRate;

  String get accountName => this._accountName;
  String get currencyId => this._currencyId;
  String? get description => this._description;
  double get amount => this._amount;
  double get exchangeRate => this._exchangeRate;

  CreateAccountRequest(this._accountName, this._currencyId, this._amount, this._exchangeRate, this._description);
}

class CreateAccountResponse {
  late final String _accountId;

  String get accountId => this._accountId;

  CreateAccountResponse(this._accountId);
}