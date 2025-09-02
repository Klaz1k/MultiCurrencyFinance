import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class DeleteAccountService implements IService<DeleteAccountRequest, DeleteAccountResponse> {
  late final IAccountRepository _accountRepository;

  DeleteAccountService({required IAccountRepository accountRepository}):
    this._accountRepository = accountRepository;

  @override
  Future<Result<DeleteAccountResponse>> execute(DeleteAccountRequest params) async {
    final deleteResult = await this._accountRepository.delete(params.accountId);

    if (deleteResult.isError) return Result.failure(deleteResult.error);

    return Result.success(DeleteAccountResponse(accountId: deleteResult.value));
  }
  
}

class DeleteAccountRequest {
  late final String accountId;

  DeleteAccountRequest({required this.accountId});
}

class DeleteAccountResponse {
  late final String accountId;

  DeleteAccountResponse({required this.accountId});
}