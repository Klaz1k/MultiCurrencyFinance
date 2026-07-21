import 'package:multi_currency_finance/controller/account/mappers/json/account_json.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/mappers/json/currency_json.dart';
import 'package:multi_currency_finance/controller/transaction/mappers/json/transaction_json.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';

class GetBackupDataService implements IService<GetBackupDataRequest, GetBackupDataResponse> {
  late final ICurrencyRepository _currencyRepository;
  late final IAccountRepository _accountRepository;
  late final ITransactionRepository _transactionRepository;

  GetBackupDataService({required ICurrencyRepository currencyRepository, required IAccountRepository accountRepository, required ITransactionRepository transactionRepository}) :
    _currencyRepository = currencyRepository,
    _accountRepository = accountRepository,
    _transactionRepository = transactionRepository;

  @override
  Future<Result<GetBackupDataResponse>> execute(GetBackupDataRequest params) async {
    final currenciesResult = await _currencyRepository.findAll(null, null);

    if (currenciesResult.isError) return Result.failure(currenciesResult.error);

    final accountsResult = await _accountRepository.findAll(null, null);

    if (accountsResult.isError) return Result.failure(accountsResult.error);

    final transactionsResult = await _transactionRepository.findAll(null, null);

    if (transactionsResult.isError) return Result.failure(transactionsResult.error);

    final List<CurrencyJson> currencies = currenciesResult.value.map((currency) => CurrencyJson.fromDomain(currency)).toList();

    final List<AccountJson> accounts = accountsResult.value.map((account) => AccountJson.fromDomain(account)).toList();

    final List<TransactionJson> transactions = transactionsResult.value.map((transaction) => TransactionJson.fromDomain(transaction)).toList();

    return Result.success(
      GetBackupDataResponse(
        currencies: currencies,
        accounts: accounts,
        transactions: transactions
      )
    );

  }

}

class GetBackupDataRequest {}

class GetBackupDataResponse {
  late final List<CurrencyJson> currencies;
  late final List<AccountJson> accounts;
  late final List<TransactionJson> transactions;

  GetBackupDataResponse({
    required this.currencies,
    required this.accounts,
    required this.transactions
  });
}