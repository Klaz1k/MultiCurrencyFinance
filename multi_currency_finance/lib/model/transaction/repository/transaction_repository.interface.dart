import 'package:multi_currency_finance/model/common/repository/repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
// import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

abstract interface class ITransactionRepository implements IRepository<Transaction> {
  Future<Result<List<Transaction>>> findByDate(int monthAsNumber, int year, int? page, int? perPage);
  Future<Result<List<Transaction>>> findByCategoryAndDate(String? categoryId, int monthAsNumber, int year);
  Future<Result<Map<String, List<Transaction>>>> findExpensesByDateGroupedByCategory(int monthAsNumber, int year);
  Future<Result<Map<String, List<Transaction>>>> findIncomeByDateGroupedByCategory(int monthAsNumber, int year);
}