import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';

class MakeWithdrawalService implements IService<MakeWithdrawalRequest, MakeWithdrawalResponse> {
  late final IAccountRepository _accountRepository;
  late final ITransactionRepository _transactionRepository;
  //TODO: ExpenseCategoryRepository
  
  MakeWithdrawalService({required IAccountRepository accountRepository, required ITransactionRepository transactionRepository})
  : this._accountRepository = accountRepository, 
  this._transactionRepository = transactionRepository;

  @override
  Future<Result<MakeWithdrawalResponse>> execute(MakeWithdrawalRequest params) {
    // TODO: implement execute
    throw UnimplementedError();
  }
  
}

class MakeWithdrawalRequest {
  late final String accountId;
  late final String? categoryId;
  late final String? description;
  late final double amount;

  MakeWithdrawalRequest({required this.accountId, this.categoryId, this.description, required this.amount});
}

class MakeWithdrawalResponse {
  late final String transactionId;

  MakeWithdrawalResponse({required this.transactionId});
}