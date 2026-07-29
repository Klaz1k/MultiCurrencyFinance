import 'package:hive/hive.dart';
import 'package:multi_currency_finance/controller/category/income/repository/hive/hive_income_category_entities.dart' show IncomeCategoryHiveObject;
import 'package:multi_currency_finance/model/category/income/errors/income_category_not_found_error.dart';
import 'package:multi_currency_finance/model/category/income/income_category.dart';
import 'package:multi_currency_finance/model/category/income/repository/income_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class HiveIncomeCategoryRepository implements IIncomeCategoryRepository {
  static final HiveIncomeCategoryRepository instance = HiveIncomeCategoryRepository._();

  HiveIncomeCategoryRepository._();
  final String dbName = 'incomeCategories';

  @override
  Future<Result<int>> clear() async {
    final box = await Hive.openBox<IncomeCategoryHiveObject>(dbName);

    final int length = box.length;

    await box.clear();

    return Result.success(length);
  }

  @override
  Future<Result<String>> delete(String id) async {
    final box = await Hive.openBox<IncomeCategoryHiveObject>(dbName);

    if (!box.containsKey(id)) return Result.failure(IncomeCategoryNotFoundError());

    await box.delete(id);

    return Result.success(id);
  }

  @override
  Future<Result<List<IncomeCategory>>> findAll(int? page, int? perPage) async {
    final box = await Hive.openBox<IncomeCategoryHiveObject>(dbName);
    final List<IncomeCategory> categories = [];

    if (page == null || perPage == null) {
      for (final hiveIncomeCategory in box.values) {
        categories.add(hiveIncomeCategory.toDomain());
      }
      return Result.success(categories);
    }

    for (final hiveIncomeCategory in box.values.skip(page*perPage).take(perPage)) {
      categories.add(hiveIncomeCategory.toDomain());
    }

    return Result.success(categories);
  }

  @override
  Future<Result<IncomeCategory>> findById(String id) async {
    final box = await Hive.openBox<IncomeCategoryHiveObject>(dbName);

    if (!box.containsKey(id)) return Result.failure(IncomeCategoryNotFoundError());

    return Result.success(box.get(id)!.toDomain());
  }

  @override
  Future<Result<String>> save(IncomeCategory entity) async {
    final box = await Hive.openBox<IncomeCategoryHiveObject>(dbName);

    await box.put(
      entity.id,
      IncomeCategoryHiveObject(
        id: entity.id, 
        name: entity.name
      )
    );

    return Result.success(entity.id);
  }

}