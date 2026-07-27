import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/category/expense/repository/expense_category_repository.interface.dart';
import 'package:multi_currency_finance/model/category/income/repository/income_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';

class ClearAllDataService implements IService<ClearAllDataServiceRequest, ClearAllDataServiceResponse> {
  final ICurrencyRepository _currencyRepository;
  final IAccountRepository _accountRepository;
  final ITransactionRepository _transactionRepository;
  final IExpenseCategoryRepository _expenseCategoryRepository;
  final IIncomeCategoryRepository _incomeCategoryRepository;

  ClearAllDataService({
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
  Future<Result<ClearAllDataServiceResponse>> execute(ClearAllDataServiceRequest params) async{
    try {

      await Future.wait([
        _transactionRepository.clear(),
        _accountRepository.clear(),
        _currencyRepository.clear(),
        _expenseCategoryRepository.clear(),
        _incomeCategoryRepository.clear()
      ]);
      
      return Result.success(ClearAllDataServiceResponse());

    } on Error catch (e, _) {
      return Result.failure(e);
    }
  } 
}

class ClearAllDataServiceRequest {

}

class ClearAllDataServiceResponse {

}