import 'package:multi_currency_finance/model/common/repository/repository.interface.dart';
// import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

abstract interface class ITransactionRepository implements IRepository<Transaction> {
  // Future<Result<List<Transaction>>> findByMonth(int monthAsNumber, int? page, int? perPage); //Temp: Uncomment when implementing monthly view screen
}