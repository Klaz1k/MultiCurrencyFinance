import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/category/expense/expense_category.dart';
import 'package:multi_currency_finance/model/category/expense/repository/expense_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class GetAllExpenseCategoriesService implements IService<GetAllExpenseCategoriesRequest, GetAllExpenseCategoriesResponse> {
  final IExpenseCategoryRepository _expenseCategoryRepository;

  GetAllExpenseCategoriesService({
    required IExpenseCategoryRepository expenseCategoryRepository
  }) : 
  _expenseCategoryRepository = expenseCategoryRepository;

  @override
  Future<Result<GetAllExpenseCategoriesResponse>> execute(GetAllExpenseCategoriesRequest params) async {
    final categoriesResult = await _expenseCategoryRepository.findAll(params.page, params.perPage);

    if (categoriesResult.isError) return Result.failure(categoriesResult.error);

    return Result.success(GetAllExpenseCategoriesResponse(categories: categoriesResult.value));
  }

}

class GetAllExpenseCategoriesRequest {
  final int? page;
  final int? perPage;

  GetAllExpenseCategoriesRequest({
    this.page,
    this.perPage
  });
}

class GetAllExpenseCategoriesResponse {
  final List<ExpenseCategory> categories;

  GetAllExpenseCategoriesResponse({
    required this.categories
  });
}