import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/category/expense/repository/expense_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class CreateExpenseCategoryService implements IService<CreateExpenseCategoryRequest, CreateExpenseCategoryResponse> {
  final IExpenseCategoryRepository _expenseCategoryRepository;

  CreateExpenseCategoryService({required IExpenseCategoryRepository expenseCategoryRepository}):
    _expenseCategoryRepository = expenseCategoryRepository;
    
  @override
  Future<Result<CreateExpenseCategoryResponse>> execute(CreateExpenseCategoryRequest params) {
    // TODO: implement execute
    throw UnimplementedError();
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