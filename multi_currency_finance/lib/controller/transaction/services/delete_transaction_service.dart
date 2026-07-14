import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/transaction/entities/transaction_data.dart';
import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';

class DeleteTransactionService implements IService<DeleteTransactionRequest, DeleteTransactionResponse> {
  late final ITransactionRepository _transactionRepository;
  late final IAccountRepository _accountRepository;
  late final ICurrencyRepository _currencyRepository;

  DeleteTransactionService({required ITransactionRepository transactionRepository, required IAccountRepository accountRepository, required ICurrencyRepository currencyRepository }) :
    _transactionRepository = transactionRepository,
    _accountRepository = accountRepository,
    _currencyRepository = currencyRepository;

  @override
  Future<Result<DeleteTransactionResponse>> execute(DeleteTransactionRequest params) async {
    final transactionResult = await _transactionRepository.findById(params.transactionId);

    final deletionResult = await _transactionRepository.delete(params.transactionId);    

    if (deletionResult.isError) return Result.failure(deletionResult.error);

    if (transactionResult.isError) return Result.failure(transactionResult.error);

    final accountResult = await _accountRepository.findById(transactionResult.value.relatedAccountId);

    if (accountResult.isError) return Result.failure(accountResult.error);

    List<BalanceAmount> rollbackedAmount = transactionResult.value.transactedAmount;
    switch (transactionResult.value.transactionType) {
      case TransactionType.Deposit:
      case TransactionType.IncomingTransfer:
        for (final balanceAmount in transactionResult.value.transactedAmount) {
          if (!accountResult.value.removeBalance(balanceAmount)) {
            if (accountResult.value.getTotalBalance() >= balanceAmount.amount) {
              rollbackedAmount = accountResult.value.withdraw(balanceAmount.amount);
            }
          }
        }
        break;

      case TransactionType.Withdrawal:
      case TransactionType.OutgoingTransfer:
        rollbackedAmount = [];
        for (final balanceAmount in transactionResult.value.transactedAmount) {
          rollbackedAmount.add(accountResult.value.deposit(balanceAmount));
        }

        break;
    }

    final accountSaveResult = await _accountRepository.save(accountResult.value);

    if (accountSaveResult.isError) return Result.failure(accountSaveResult.error);

    String currencySymbol = " ";

    final currencyResult = await this._currencyRepository.findById(transactionResult.value.currencyId);

    if (!currencyResult.isError) currencySymbol = currencyResult.value.symbol;

    return Result.success(DeleteTransactionResponse(
      deletedTransaction: TransactionData(
        id: params.transactionId,
        type: transactionResult.value.transactionType, 
        date: transactionResult.value.date, 
        currencySymbol: currencySymbol, 
        balanceList: rollbackedAmount, 
        totalAmount: transactionResult.value.getTotalTransacted(), 
        exchangedTotal: transactionResult.value.getExchangedTotal(), 
        relatedAccountName: transactionResult.value.relatedAccountId)
    ));

  }

}

class DeleteTransactionRequest {
  late final String transactionId;

  DeleteTransactionRequest({
    required this.transactionId
  });
}

class DeleteTransactionResponse {
  late final TransactionData deletedTransaction;

  DeleteTransactionResponse({
    required this.deletedTransaction
  });
}