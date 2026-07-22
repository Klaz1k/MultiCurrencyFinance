import 'package:multi_currency_finance/controller/account/mappers/json/account_json.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/mappers/json/currency_json.dart';
import 'package:multi_currency_finance/controller/transaction/mappers/json/transaction_json.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';

class LoadDataFromBackupService implements IService<LoadDataFromBackupRequest, LoadDataFromBackupResponse> {
  late final ICurrencyRepository _currencyRepository;
  late final IAccountRepository _accountRepository;
  late final ITransactionRepository _transactionRepository;

  LoadDataFromBackupService({required ICurrencyRepository currencyRepository, required IAccountRepository accountRepository, required ITransactionRepository transactionRepository}) :
    _currencyRepository = currencyRepository,
    _accountRepository = accountRepository,
    _transactionRepository = transactionRepository;

  @override
  Future<Result<LoadDataFromBackupResponse>> execute(LoadDataFromBackupRequest params) async {
    
    for (final currency in params.currencies) {
      final currencySaveResult = await _currencyRepository.save(currency.toDomain());

      if (currencySaveResult.isError) return Result.failure(currencySaveResult.error);
    }

    for (final account in params.accounts) {
      final accountSaveResult = await _accountRepository.save(account.toDomain());

      if (accountSaveResult.isError) return Result.failure(accountSaveResult.error);
    }

    for (final transaction in params.transactions) {
      final transactionSaveResult = await _transactionRepository.save(transaction.toDomain());

      if (transactionSaveResult.isError) return Result.failure(transactionSaveResult.error);
    }

    return Result.success(LoadDataFromBackupResponse());
  }
}

class LoadDataFromBackupRequest {
  late final List<CurrencyJson> currencies;
  late final List<AccountJson> accounts;
  late final List<TransactionJson> transactions;

  LoadDataFromBackupRequest({
    required this.currencies,
    required this.accounts,
    required this.transactions
  });
}

class LoadDataFromBackupResponse {}