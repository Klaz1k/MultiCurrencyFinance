import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class EditAccountService implements IService<EditAccountRequest, EditAccountResponse> {
  late final IAccountRepository _accountRepository;

  EditAccountService({required IAccountRepository accountRepository}):
    this._accountRepository = accountRepository;

  @override
  Future<Result<EditAccountResponse>> execute(EditAccountRequest params) async {
    final accountResult = await this._accountRepository.findById(params.accountId);

    if (accountResult.isError) return Result.failure(accountResult.error);

    accountResult.value.name = params.accountName;
    accountResult.value.description = params.accountDescription;

    final saveResult = await this._accountRepository.save(accountResult.value);

    if (saveResult.isError) return Result.failure(saveResult.error);

    return Result.success(EditAccountResponse(accountId: saveResult.value));
  }

}

class EditAccountRequest {
  late final String accountId;
  late final String accountName;
  late final String? accountDescription;

  EditAccountRequest({required this.accountId, required this.accountName, this.accountDescription});
}

class EditAccountResponse {
  late final String accountId;

  EditAccountResponse({required this.accountId});
}