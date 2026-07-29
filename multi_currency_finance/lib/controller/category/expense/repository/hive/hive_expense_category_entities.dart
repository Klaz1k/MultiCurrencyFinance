import 'package:hive/hive.dart';
import 'package:multi_currency_finance/controller/common/hive/hive_type_constants.dart';
import 'package:multi_currency_finance/model/category/expense/expense_category.dart';

part 'hive_expense_category_entities.g.dart';

@HiveType(typeId: HiveConstants.ExpenseCategoryHiveId)
class ExpenseCategoryHiveObject extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  ExpenseCategoryHiveObject({
    required this.id,
    required this.name
  });

  ExpenseCategory toDomain() {
    return ExpenseCategory(
      id: this.id,
      name: this.name
    );
  }
}