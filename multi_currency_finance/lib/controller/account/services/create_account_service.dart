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

  CreateAccountService({required IAccountRepository accountRepository, required ICurrencyRepository currencyRepository }) :
    this._accountRepository = accountRepository,
    this._currencyRepository = currencyRepository;

  @override
  Future<Result<CreateAccountResponse>> execute(CreateAccountRequest params) async {
    final currencyResult = await this._currencyRepository.findById(params.currencyId);

    if (currencyResult.isError) return Result.failure(currencyResult.error);

    late final double mainCurrencyEquivalent;
    if (currencyResult.value.isMain) {
      mainCurrencyEquivalent = params.amount;
    } else {
      mainCurrencyEquivalent = params.mainCurrencyEquivalent;
    }

    final uuidGenerator = UuidGenerator.instance;

    final saveResult = await this._accountRepository.save(
      Account(
        id: uuidGenerator.v4(),
        name: params.accountName,
        description: params.description,
        currencyId: currencyResult.value.id,
        balance: Balance(balanceQueue: [BalanceAmount(amount: params.amount, exchangeRate: params.amount / mainCurrencyEquivalent)])
      )
    );

    if (saveResult.isError) return Result.failure(saveResult.error);

    return Result.success(CreateAccountResponse(accountId: saveResult.value));
  }

}

class CreateAccountRequest {
  late final String accountName;
  late final String currencyId;
  late final String? description;
  late final double amount;
  late final double mainCurrencyEquivalent;

  CreateAccountRequest({required this.accountName, required this.currencyId, this.description, required this.amount, required this.mainCurrencyEquivalent});
}

class CreateAccountResponse {
  late final String accountId;

  CreateAccountResponse({required this.accountId});
}