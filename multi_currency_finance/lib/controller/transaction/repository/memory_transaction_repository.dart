import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/errors/transaction_not_found_error.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

class MemoryTransactionRepository implements ITransactionRepository {
  final List<Transaction> _transactionList = [];
  static late final MemoryTransactionRepository? _instance;

  MemoryTransactionRepository get instance {
    if (MemoryTransactionRepository._instance == null) MemoryTransactionRepository._instance = MemoryTransactionRepository._();

    return MemoryTransactionRepository._instance!;
  }

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