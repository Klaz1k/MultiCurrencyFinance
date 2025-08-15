import 'package:multi_currency_finance/controller/account/entities/account_data.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/account/account.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';

class GetAllAccountsService implements IService<GetAllAccountsRequest, GetAllAccountsResponse> {
  late final IAccountRepository _accountRepository;
  late final ICurrencyRepository _currencyRepository;

  GetAllAccountsService(this._accountRepository, this._currencyRepository);

  @override
  Future<Result<GetAllAccountsResponse>> execute(GetAllAccountsRequest params) async {
    final accountsResult = await this._accountRepository.findAll(params.page, params.perPage);

    if (accountsResult.isError) return Result.failure(accountsResult.error);

    List<AccountData> accountDataList = [];
    for (Account acc in accountsResult.value) {
      final currencyResult = await this._currencyRepository.findById(acc.currencyId);

      String currencySymbol = '';
      if (!currencyResult.isError) currencySymbol = currencyResult.value.symbol;

      accountDataList.add(AccountData(
        acc.id, 
        acc.name, 
        acc.description, 
        currencySymbol, 
        acc.balance
      ));
    }

    return Result.success(GetAllAccountsResponse(accounts: accountDataList));
  }
}

class GetAllAccountsRequest {
  late final int? page;
  late final int? perPage;

  GetAllAccountsRequest.pag(this.page, this.perPage);
  GetAllAccountsRequest();
}

class GetAllAccountsResponse {
  late List<AccountData> accounts;

  GetAllAccountsResponse({required this.accounts});
}