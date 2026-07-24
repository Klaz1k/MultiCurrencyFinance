import 'package:multi_currency_finance/model/category/expense/expense_category.dart';
import 'package:multi_currency_finance/model/category/expense/repository/expense_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class HiveExpenseCategoryRepository implements IExpenseCategoryRepository {
  @override
  Future<Result<int>> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<Result<String>> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Result<List<ExpenseCategory>>> findAll(int? page, int? perPage) {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  Future<Result<ExpenseCategory>> findById(String id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  Future<Result<String>> save(ExpenseCategory entity) {
    // TODO: implement save
    throw UnimplementedError();
  }

}