import 'package:hive/hive.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_entities.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_entities.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/errors/transaction_not_found_error.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

class HiveTransactionRepository implements ITransactionRepository {
  static final HiveTransactionRepository instance = HiveTransactionRepository._();

  HiveTransactionRepository._();
  final String dbName = 'transactions';

  @override
  Future<Result<List<Transaction>>> findAll(int? page, int? perPage) async {
    final box = await Hive.openBox<TransactionHiveObject>(dbName);
    final List<Transaction> transactions = [];

    if (page == null || perPage == null) {
      for (final hiveTransaction in box.values) {
        transactions.add(hiveTransaction.toDomain());
      }
      return Result.success(transactions);
    }

    for (final hiveTransaction in box.values.skip(page*perPage).take(perPage)) {
      transactions.add(hiveTransaction.toDomain());
    }

    return Result.success(transactions);
  }

  @override
  Future<Result<Transaction>> findById(String id) async {
    final box = await Hive.openBox<TransactionHiveObject>(dbName);

    if (!box.containsKey(id)) return Result.failure(TransactionNotFoundError());

    return Result.success(box.get(id)!.toDomain());
  }

  @override
  Future<Result<String>> save(Transaction transaction) async {
    final box = await Hive.openBox<TransactionHiveObject>(dbName);

    final List<BalanceHiveObject> hiveSubBalances = [];
    for (final subBalance in transaction.transactedAmount) {
      hiveSubBalances.add(
        BalanceHiveObject(
          amount: subBalance.amount, 
          exchangeRate: subBalance.exchangeRate
        )
      );
    }

    await box.put(
      transaction.id, 
      TransactionHiveObject(
        id: transaction.id, 
        transactionType: TransactionTypeHiveObject.values.firstWhere((type) => type.name == transaction.transactionType.name), 
        date: transaction.date, 
        currencyId: transaction.currencyId, 
        description: transaction.description, 
        transactedAmount: hiveSubBalances, 
        relatedAccountId: transaction.relatedAccountId
      )
    );

    return Result.success(transaction.id);
  }

}