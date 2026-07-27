import 'package:json_annotation/json_annotation.dart';
import 'package:multi_currency_finance/model/category/expense/expense_category.dart';

part 'expense_category_json.g.dart';

@JsonSerializable()
class ExpenseCategoryJson {
  final String id;
  final String name;

  ExpenseCategoryJson({
    required this.id,
    required this.name
  });

  factory ExpenseCategoryJson.fromJson(Map<String, dynamic> json) => _$ExpenseCategoryJsonFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseCategoryJsonToJson(this);

  factory ExpenseCategoryJson.fromDomain(ExpenseCategory category) {
    return ExpenseCategoryJson(
      id: category.id,
      name: category.name
    );
  }

  ExpenseCategory toDomain() {
    return ExpenseCategory(
      id: this.id, 
      name: this.name
    );
  }
}