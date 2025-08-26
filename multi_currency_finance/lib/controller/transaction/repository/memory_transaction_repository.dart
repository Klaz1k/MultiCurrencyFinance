import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/errors/transaction_not_found_error.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

class MemoryTransactionRepository implements ITransactionRepository {
  // final List<Transaction> _transactionList = [];
  final List<Transaction> _transactionList = [Transaction(id: "1", transactionType: TransactionType.Deposit, description: 'Test Description',date: DateTime.now(), currencyId: "1", transactedAmount: [BalanceAmount(amount: 100, exchangeRate: 25)], relatedAccountId: "1")];
  static final MemoryTransactionRepository instance = MemoryTransactionRepository._();

  MemoryTransactionRepository._();

  @override
  Future<Result<List<Transaction>>> findAll(int? page, int? perPage) async {
    if (page == null || perPage == null) return Result.success(this._transactionList);

    int start = (page)*perPage;
    int end = start + perPage;

    if (end >= this._transactionList.length) end = this._transactionList.length;

    return Result.success(this._transactionList.getRange(start, end).toList());
  }

  @override
  Future<Result<Transaction>> findById(String id) async {
    for (Transaction acc in this._transactionList) {
      if (acc.id == id) {
        return Result.success(acc);
      }
    }

    return Result.failure(TransactionNotFoundError());
  }

  @override
  Future<Result<String>> save(Transaction transaction) async {
    for (Transaction acc in this._transactionList) {
      if (acc.id == transaction.id) {

        return Result.success(acc.id);
      }
    }
    this._transactionList.add(transaction);
    return Result.success(transaction.id);
  }

}