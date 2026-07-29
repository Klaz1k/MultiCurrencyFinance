import 'package:json_annotation/json_annotation.dart';
import 'package:multi_currency_finance/model/category/income/income_category.dart';

part 'income_category_json.g.dart';

@JsonSerializable()
class IncomeCategoryJson {
  final String id;
  final String name;

  IncomeCategoryJson({
    required this.id,
    required this.name
  });

  factory IncomeCategoryJson.fromJson(Map<String, dynamic> json) => _$IncomeCategoryJsonFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeCategoryJsonToJson(this);

  factory IncomeCategoryJson.fromDomain(IncomeCategory category) {
    return IncomeCategoryJson(
      id: category.id,
      name: category.name
    );
  }

  IncomeCategory toDomain() {
    return IncomeCategory(
      id: this.id, 
      name: this.name
    );
  }
}