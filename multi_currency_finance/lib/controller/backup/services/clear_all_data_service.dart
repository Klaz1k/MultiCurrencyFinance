import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';

class ClearAllDataService implements IService<ClearAllDataServiceRequest, ClearAllDataServiceResponse> {
  late final ICurrencyRepository _currencyRepository;
  late final IAccountRepository _accountRepository;
  late final ITransactionRepository _transactionRepository;

  ClearAllDataService({required ICurrencyRepository currencyRepository, required IAccountRepository accountRepository, required ITransactionRepository transactionRepository}) :
    _currencyRepository = currencyRepository,
    _accountRepository = accountRepository,
    _transactionRepository = transactionRepository;

  @override
  Future<Result<ClearAllDataServiceResponse>> execute(ClearAllDataServiceRequest params) async{
    try {

      await Future.wait([
        _transactionRepository.clear(),
        _accountRepository.clear(),
        _currencyRepository.clear()
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