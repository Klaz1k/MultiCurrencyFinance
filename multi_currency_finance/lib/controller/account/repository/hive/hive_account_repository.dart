import 'package:hive/hive.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_entities.dart';
import 'package:multi_currency_finance/model/account/account.dart';
import 'package:multi_currency_finance/model/account/errors/account_not_found_error.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class HiveAccountRepository implements IAccountRepository {

  static final HiveAccountRepository instance = HiveAccountRepository._();

  HiveAccountRepository._();
  final String dbName = 'accounts';

  @override
  Future<Result<List<Account>>> findAll(int? page, int? perPage) async {
    final box = await Hive.openBox<AccountHiveObject>(dbName);
    final List<Account> accounts = [];

    if (page == null || perPage == null) {
      for (final hiveAccount in box.values) {
        accounts.add(hiveAccount.toDomain());
      }
      return Result.success(accounts);
    }

    for (final hiveAccount in box.values.skip(page*perPage).take(perPage)) {
      accounts.add(hiveAccount.toDomain());
    }

    return Result.success(accounts);
  }

  @override
  Future<Result<Account>> findById(String id) async {
    final box = await Hive.openBox<AccountHiveObject>(dbName);

    if (!box.containsKey(id)) return Result.failure(AccountNotFoundError());

    return Result.success(box.get(id)!.toDomain());
  }

  @override
  Future<Result<String>> save(Account account) async {
    final box = await Hive.openBox<AccountHiveObject>(dbName);

    final List<BalanceHiveObject> hiveSubBalances = [];
    for (final subBalance in account.balance.balanceQueue) {
      hiveSubBalances.add(
        BalanceHiveObject(
          amount: subBalance.amount, 
          exchangeRate: subBalance.exchangeRate
        )
      );
    }

    await box.put(
      account.id,
      AccountHiveObject(
        id: account.id, 
        name: account.name,
        description: account.description, 
        currencyId: account.currencyId, 
        balance: hiveSubBalances
      )
    );

    return Result.success(account.id);
  }
  
  @override
  Future<Result<String>> delete(String id) async {
    final box = await Hive.openBox<AccountHiveObject>(dbName);

    if (!box.containsKey(id)) return Result.failure(AccountNotFoundError());

    await box.delete(id);

    return Result.success(id);
  }
  
  @override
  Future<Result<int>> clear() async {
    final box = await Hive.openBox<AccountHiveObject>(dbName);

    final int length = box.length;

    await box.clear();

    return Result.success(length);
  }

}