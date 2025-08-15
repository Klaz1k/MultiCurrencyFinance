import 'package:multi_currency_finance/model/common/repository/repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

abstract interface class ITransactionRepository implements IRepository<Transaction> {
  //Eventually this will need to add a "Find by month" method
}