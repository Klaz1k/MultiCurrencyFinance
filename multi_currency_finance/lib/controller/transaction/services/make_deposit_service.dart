import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/common/uuid/uuid_generator.dart';
import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

class MakeDepositService implements IService<MakeDepositRequest, MakeDepositResponse> {
  late final IAccountRepository _accountRepository;
  late final ITransactionRepository _transactionRepository;
  //TODO: CategoryRepository goes here

  MakeDepositService({required IAccountRepository accountRepository, required ITransactionRepository transactionRepository});

  @override
  Future<Result<MakeDepositResponse>> execute(MakeDepositRequest params) async {
    final accountResult = await this._accountRepository.findById(params.accountId);

    if (accountResult.isError) return Result.failure(accountResult.error);

    final depositedBalance = accountResult.value.deposit(BalanceAmount(amount: params.amount, exchangeRate: params.exchangeRate));
    final accountSaveResult = await this._accountRepository.save(accountResult.value);

    if (accountSaveResult.isError) return Result.failure(accountSaveResult.error);

    final uuidGenerator = UuidGenerator.instance;

    final transactionSaveResult = await this._transactionRepository.save(
      Transaction(
        id: uuidGenerator.v4(), 
        transactionType: TransactionType.Deposit,  
        date: DateTime.now(),
        currencyId: accountResult.value.currencyId, 
        description: params.description, 
        transactedAmount: [depositedBalance], 
        relatedAccountId: accountResult.value.id
      )
    );
    if (transactionSaveResult.isError) return Result.failure(transactionSaveResult.error);

    return Result.success(MakeDepositResponse(transactionId: transactionSaveResult.value));
  }
}

class MakeDepositRequest {
  late final String accountId;
  late final String? categoryId;
  late final String? description;
  late final double amount;
  late final double exchangeRate;

  MakeDepositRequest({required this.accountId, this.categoryId, this.description, required this.amount, required this.exchangeRate});
}

class MakeDepositResponse {
  late final String transactionId;

  MakeDepositResponse({required this.transactionId});
}