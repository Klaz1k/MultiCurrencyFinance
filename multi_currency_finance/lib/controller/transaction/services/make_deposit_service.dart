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

  MakeDepositService({required ITransactionRepository transactionRepository, required IAccountRepository accountRepository }) :
    _transactionRepository = transactionRepository,
    _accountRepository = accountRepository;

  @override
  Future<Result<MakeDepositResponse>> execute(MakeDepositRequest params) async {
    final accountResult = await this._accountRepository.findById(params.accountId);

    if (accountResult.isError) return Result.failure(accountResult.error);
    final rollbackAccount = accountResult.value.clone();

    final depositedBalance = accountResult.value.deposit(BalanceAmount(amount: params.amountDeposited, exchangeRate: params.amountDeposited / params.mainCurrencyEquivalent));
    final accountSaveResult = await this._accountRepository.save(accountResult.value);

    if (accountSaveResult.isError) return Result.failure(accountSaveResult.error);

    final uuidGenerator = UuidGenerator.instance;

    final transactionSaveResult = await this._transactionRepository.save(
      Transaction(
        id: uuidGenerator.v4(), 
        transactionType: TransactionType.Deposit,
        categoryId: params.categoryId,
        date: DateTime.now(),
        currencyId: accountResult.value.currencyId, 
        description: params.description, 
        transactedAmount: [depositedBalance], 
        relatedAccountId: accountResult.value.id
      )
    );
    
    if (transactionSaveResult.isError) {
      await this._accountRepository.save(rollbackAccount);
      return Result.failure(transactionSaveResult.error);
    }

    return Result.success(MakeDepositResponse(transactionId: transactionSaveResult.value));
  }
}

class MakeDepositRequest {
  late final String accountId;
  late final String? categoryId;
  late final String? description;
  late final double amountDeposited;
  late final double mainCurrencyEquivalent;

  MakeDepositRequest({required this.accountId, this.categoryId, this.description, required this.amountDeposited, required this.mainCurrencyEquivalent});
}

class MakeDepositResponse {
  late final String transactionId;

  MakeDepositResponse({required this.transactionId});
}