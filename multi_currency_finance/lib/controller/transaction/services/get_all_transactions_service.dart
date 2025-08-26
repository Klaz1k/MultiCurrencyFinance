import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/transaction/entities/transaction_data.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';

class GetAllTransactionsService implements IService<GetAllTransactionsRequest, GetAllTransactionsResponse> {
  late final ITransactionRepository _transactionRepository;
  late final IAccountRepository _accountRepository;
  late final ICurrencyRepository _currencyRepository;

  GetAllTransactionsService({required ITransactionRepository transactionRepository, required IAccountRepository accountRepository, required ICurrencyRepository currencyRepository}) : 
    this._transactionRepository = transactionRepository,
    this._accountRepository = accountRepository,
    this._currencyRepository = currencyRepository;

  @override
  Future<Result<GetAllTransactionsResponse>> execute(GetAllTransactionsRequest params) async {
    final transactionsResult = await this._transactionRepository.findAll(params.page, params.perPage);

    if (transactionsResult.isError) return Result.failure(transactionsResult.error);

    final List<TransactionData> transactionList = [];
    for (final transaction in transactionsResult.value) {
      String accountName = '';
      String currencySymbol = '';

      final accountResult = await this._accountRepository.findById(transaction.relatedAccountId);

      if (!accountResult.isError) accountName = accountResult.value.name;

      final currencyResult = await this._currencyRepository.findById(transaction.currencyId);

      if (!currencyResult.isError) currencySymbol = currencyResult.value.symbol;

      transactionList.add(
        TransactionData(
          type: transaction.transactionType, 
          date: transaction.date, 
          currencySymbol: currencySymbol,
          description: transaction.description,
          balanceList: transaction.transactedAmount, 
          totalAmount: transaction.getTotalTransacted(), 
          exchangedTotal: transaction.getExchangedTotal(), 
          relatedAccountName: accountName
        )
      );
    }

    return Result.success(GetAllTransactionsResponse(transactions: transactionList));
  }
}

class GetAllTransactionsRequest {
  late final int? page;
  late final int? perPage;

  GetAllTransactionsRequest({this.page, this.perPage});
}

class GetAllTransactionsResponse {
  late final List<TransactionData> transactions;

  GetAllTransactionsResponse({required this.transactions});
}