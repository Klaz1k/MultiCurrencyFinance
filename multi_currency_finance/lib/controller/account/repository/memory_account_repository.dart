import 'package:multi_currency_finance/model/account/account.dart';
import 'package:multi_currency_finance/model/account/errors/account_not_found_error.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class MemoryAccountRepository implements IAccountRepository {
  List<Account> accountList = [];

  @override
  Future<Result<List<Account>>> findAll(int page, int perPage) async {
    int start = (page - 1)*perPage;
    int end = start + perPage;

    if (end >= this.accountList.length) end = this.accountList.length - 1;

    return Result.success(this.accountList.getRange(start, end).toList());
  }

  @override
  Future<Result<Account>> findById(String id) async {
    for (Account acc in this.accountList) {
      if (acc.id == id) {
        return Result.success(acc);
      }
    }

    return Result.failure(AccountNotFoundError());
  }

  @override
  Future<Result<String>> save(Account account) async {
    for (Account acc in this.accountList) {
      if (acc.id == account.id) {

        return Result.success("Account Saved");
      }
    }
    this.accountList.add(account);
    return Result.success("Account Added & Saved");
  }

}