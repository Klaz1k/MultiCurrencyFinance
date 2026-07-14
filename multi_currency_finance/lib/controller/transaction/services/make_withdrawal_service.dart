import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/common/uuid/uuid_generator.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

class MakeWithdrawalService implements IService<MakeWithdrawalRequest, MakeWithdrawalResponse> {
  late final IAccountRepository _accountRepository;
  late final ITransactionRepository _transactionRepository;
  //TODO: ExpenseCategoryRepository
  
  MakeWithdrawalService({ required ITransactionRepository transactionRepository, required IAccountRepository accountRepository}) : 
    this._accountRepository = accountRepository, 
    this._transactionRepository = transactionRepository;

  @override
  Future<Result<MakeWithdrawalResponse>> execute(MakeWithdrawalRequest params) async {
    final accountResult = await this._accountRepository.findById(params.accountId);

    if (accountResult.isError) return Result.failure(accountResult.error);
    final rollbackAccount = accountResult.value.clone();

    final withdrawedBalance = accountResult.value.withdraw(params.amount);
    final accountSaveResult = await this._accountRepository.save(accountResult.value);

    if (accountSaveResult.isError) return Result.failure(accountSaveResult.error);

    final uuidGenerator = UuidGenerator.instance;

    final transactionSaveResult = await this._transactionRepository.save(
      Transaction(
        id: uuidGenerator.v4(), 
        transactionType: TransactionType.Withdrawal,
        categoryId: params.categoryId,
        date: DateTime.now(), 
        currencyId: accountResult.value.currencyId,
        description: params.description,
        transactedAmount: withdrawedBalance, 
        relatedAccountId: accountSaveResult.value
      )
    );

    if (transactionSaveResult.isError) {
      await this._accountRepository.save(rollbackAccount);
      return Result.failure(transactionSaveResult.error);
    }

    return Result.success(MakeWithdrawalResponse(transactionId: transactionSaveResult.value));
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