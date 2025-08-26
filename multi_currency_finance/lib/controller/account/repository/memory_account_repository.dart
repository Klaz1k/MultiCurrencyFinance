import 'package:multi_currency_finance/model/account/account.dart';
import 'package:multi_currency_finance/model/account/entities/balance.dart';
import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/account/errors/account_not_found_error.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class MemoryAccountRepository implements IAccountRepository {
  // final List<Account> _accountList = [];
  final List<Account> _accountList = [Account(id: '1', name: 'TestAccount', currencyId: '1', balance: Balance(balanceQueue: [BalanceAmount(amount: 10.0, exchangeRate: 1.0)]))];
  static final MemoryAccountRepository _instance = MemoryAccountRepository._();

  static MemoryAccountRepository get instance {

    return MemoryAccountRepository._instance;
  }

  MemoryAccountRepository._();
  @override
  Future<Result<List<Account>>> findAll(int? page, int? perPage) async {
    if (page == null || perPage == null) return Result.success(this._accountList);

    int start = (page)*perPage;
    int end = start + perPage;

    if (end >= this._accountList.length) end = this._accountList.length;

    return Result.success(this._accountList.getRange(start, end).toList());
  }

  @override
  Future<Result<Account>> findById(String id) async {
    for (Account acc in this._accountList) {
      if (acc.id == id) {
        return Result.success(acc);
      }
    }

    return Result.failure(AccountNotFoundError());
  }

  @override
  Future<Result<String>> save(Account account) async {
    for (Account acc in this._accountList) {
      if (acc.id == account.id) {

        return Result.success(acc.id);
      }
    }
    this._accountList.add(account);
    return Result.success(account.id);
  }

}