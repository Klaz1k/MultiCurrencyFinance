import 'package:multi_currency_finance/controller/account/mappers/json/account_json.dart';
import 'package:multi_currency_finance/controller/category/expense/mappers/json/expense_category_json.dart';
import 'package:multi_currency_finance/controller/category/income/mappers/json/income_category_json.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/mappers/json/currency_json.dart';
import 'package:multi_currency_finance/controller/transaction/mappers/json/transaction_json.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/category/expense/repository/expense_category_repository.interface.dart';
import 'package:multi_currency_finance/model/category/income/repository/income_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';

class LoadDataFromBackupService implements IService<LoadDataFromBackupRequest, LoadDataFromBackupResponse> {
  final ICurrencyRepository _currencyRepository;
  final IAccountRepository _accountRepository;
  final ITransactionRepository _transactionRepository;
  final IExpenseCategoryRepository _expenseCategoryRepository;
  final IIncomeCategoryRepository _incomeCategoryRepository;

  LoadDataFromBackupService({
    required ICurrencyRepository currencyRepository, 
    required IAccountRepository accountRepository, 
    required ITransactionRepository transactionRepository,
    required IExpenseCategoryRepository expenseCategoryRepository,
    required IIncomeCategoryRepository incomeCategoryRepository
  }) :
    _currencyRepository = currencyRepository,
    _accountRepository = accountRepository,
    _transactionRepository = transactionRepository,
    _expenseCategoryRepository = expenseCategoryRepository,
    _incomeCategoryRepository = incomeCategoryRepository;

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

    for (final expenseCategory in params.expenseCategories) {
      final expenseCategorySaveResult = await _expenseCategoryRepository.save(expenseCategory.toDomain());

      if (expenseCategorySaveResult.isError) return Result.failure(expenseCategorySaveResult.error);
    }

    for (final incomeCategory in params.incomeCategories) {
      final incomeCategorySaveResult = await _incomeCategoryRepository.save(incomeCategory.toDomain());

      if (incomeCategorySaveResult.isError) return Result.failure(incomeCategorySaveResult.error);
    }

    return Result.success(LoadDataFromBackupResponse());
  }
}

class LoadDataFromBackupRequest {
  final List<CurrencyJson> currencies;
  final List<AccountJson> accounts;
  final List<TransactionJson> transactions;
  final List<ExpenseCategoryJson> expenseCategories;
  final List<IncomeCategoryJson> incomeCategories;

  LoadDataFromBackupRequest({
    required this.currencies,
    required this.accounts,
    required this.transactions,
    required this.expenseCategories,
    required this.incomeCategories
  });
}

class LoadDataFromBackupResponse {}