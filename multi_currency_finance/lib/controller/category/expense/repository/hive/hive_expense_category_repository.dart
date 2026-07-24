import 'package:hive/hive.dart';
import 'package:multi_currency_finance/controller/category/expense/repository/hive/hive_expense_category_entities.dart';
import 'package:multi_currency_finance/model/category/expense/errors/expense_category_not_found_error.dart';
import 'package:multi_currency_finance/model/category/expense/expense_category.dart';
import 'package:multi_currency_finance/model/category/expense/repository/expense_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class HiveExpenseCategoryRepository implements IExpenseCategoryRepository {
  static final HiveExpenseCategoryRepository instance = HiveExpenseCategoryRepository._();

  HiveExpenseCategoryRepository._();
  final String dbName = 'expenseCategories';

  @override
  Future<Result<ExpenseCategory>> findById(String id) async {
    final box = await Hive.openBox<ExpenseCategoryHiveObject>(dbName);

    if (!box.containsKey(id)) return Result.failure(ExpenseCategoryNotFoundError());

    return Result.success(box.get(id)!.toDomain());
  }

  @override
  Future<Result<List<ExpenseCategory>>> findAll(int? page, int? perPage) async {
    final box = await Hive.openBox<ExpenseCategoryHiveObject>(dbName);
    final List<ExpenseCategory> categories = [];

    if (page == null || perPage == null) {
      for (final hiveExpenseCategory in box.values) {
        categories.add(hiveExpenseCategory.toDomain());
      }
      return Result.success(categories);
    }

    for (final hiveExpenseCategory in box.values.skip(page*perPage).take(perPage)) {
      categories.add(hiveExpenseCategory.toDomain());
    }

    return Result.success(categories);
  }

  @override
  Future<Result<String>> save(ExpenseCategory entity) async {
    final box = await Hive.openBox<ExpenseCategoryHiveObject>(dbName);

    await box.put(
      entity.id,
      ExpenseCategoryHiveObject(
        id: entity.id, 
        name: entity.name
      )
    );

    return Result.success(entity.id);
  }

  @override
  Future<Result<String>> delete(String id) async {
    final box = await Hive.openBox<ExpenseCategoryHiveObject>(dbName);

    if (!box.containsKey(id)) return Result.failure(ExpenseCategoryNotFoundError());

    await box.delete(id);

    return Result.success(id);
  }

  @override
  Future<Result<int>> clear() async {
    final box = await Hive.openBox<ExpenseCategoryHiveObject>(dbName);

    final int length = box.length;

    await box.clear();

    return Result.success(length);
  }
}