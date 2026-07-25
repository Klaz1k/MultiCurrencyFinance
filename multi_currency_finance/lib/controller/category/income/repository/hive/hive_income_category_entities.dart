import 'package:hive/hive.dart';
import 'package:multi_currency_finance/controller/common/hive/hive_type_constants.dart';
import 'package:multi_currency_finance/model/category/income/income_category.dart';

part 'hive_income_category_entities.g.dart';

@HiveType(typeId: HiveConstants.IncomeCategoryHiveId)
class IncomeCategoryHiveObject extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  IncomeCategoryHiveObject({
    required this.id,
    required this.name
  });

  IncomeCategory toDomain() {
    return IncomeCategory(
      id: this.id,
      name: this.name
    );
  }
}