import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/common/uuid/uuid_generator.dart';
import 'package:multi_currency_finance/model/category/expense/expense_category.dart';
import 'package:multi_currency_finance/model/category/expense/repository/expense_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class CreateExpenseCategoryService implements IService<CreateExpenseCategoryRequest, CreateExpenseCategoryResponse> {
  final IExpenseCategoryRepository _expenseCategoryRepository;

  CreateExpenseCategoryService({required IExpenseCategoryRepository expenseCategoryRepository}):
    _expenseCategoryRepository = expenseCategoryRepository;
    
  @override
  Future<Result<CreateExpenseCategoryResponse>> execute(CreateExpenseCategoryRequest params) async {
    final saveResult = await _expenseCategoryRepository.save(
      ExpenseCategory(
        id: UuidGenerator.instance.v4(),
        name: params.categoryName
      )
    );

    if (saveResult.isError) return Result.failure(saveResult.error);

    return Result.success(CreateExpenseCategoryResponse(categoryId: saveResult.value));
  }

  
}

class CreateExpenseCategoryRequest {
  final String categoryName;

  CreateExpenseCategoryRequest({
    required this.categoryName
  });
}

class CreateExpenseCategoryResponse {
  final String categoryId;

  CreateExpenseCategoryResponse({
    required this.categoryId
  });
}