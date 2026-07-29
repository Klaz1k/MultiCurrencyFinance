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

class GetBackupDataService implements IService<GetBackupDataRequest, GetBackupDataResponse> {
  final ICurrencyRepository _currencyRepository;
  final IAccountRepository _accountRepository;
  final ITransactionRepository _transactionRepository;
  final IExpenseCategoryRepository _expenseCategoryRepository;
  final IIncomeCategoryRepository _incomeCategoryRepository;


  GetBackupDataService({
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
  Future<Result<GetBackupDataResponse>> execute(GetBackupDataRequest params) async {
    final currenciesResult = await _currencyRepository.findAll(null, null);

    if (currenciesResult.isError) return Result.failure(currenciesResult.error);

    final accountsResult = await _accountRepository.findAll(null, null);

    if (accountsResult.isError) return Result.failure(accountsResult.error);

    final transactionsResult = await _transactionRepository.findAll(null, null);

    if (transactionsResult.isError) return Result.failure(transactionsResult.error);

    final expenseCategoriesResult = await _expenseCategoryRepository.findAll(null, null);

    if (expenseCategoriesResult.isError) return Result.failure(expenseCategoriesResult.error);

    final incomeCategoriesResult = await _incomeCategoryRepository.findAll(null, null);

    if (incomeCategoriesResult.isError) return Result.failure(incomeCategoriesResult.error);

    final List<CurrencyJson> currencies = currenciesResult.value.map((currency) => CurrencyJson.fromDomain(currency)).toList();

    final List<AccountJson> accounts = accountsResult.value.map((account) => AccountJson.fromDomain(account)).toList();

    final List<TransactionJson> transactions = transactionsResult.value.map((transaction) => TransactionJson.fromDomain(transaction)).toList();

    final List<ExpenseCategoryJson> expenseCategories = expenseCategoriesResult.value.map((expenseCategory) => ExpenseCategoryJson.fromDomain(expenseCategory)).toList();

    final List<IncomeCategoryJson> incomeCategories = incomeCategoriesResult.value.map((incomeCategory) => IncomeCategoryJson.fromDomain(incomeCategory)).toList();

    return Result.success(
      GetBackupDataResponse(
        currencies: currencies,
        accounts: accounts,
        transactions: transactions,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories
      )
    );

  }

}

class GetBackupDataRequest {}

class GetBackupDataResponse {
  final List<CurrencyJson> currencies;
  final List<AccountJson> accounts;
  final List<TransactionJson> transactions;
  final List<ExpenseCategoryJson> expenseCategories;
  final List<IncomeCategoryJson> incomeCategories;

  GetBackupDataResponse({
    required this.currencies,
    required this.accounts,
    required this.transactions,
    required this.expenseCategories,
    required this.incomeCategories
  });
}