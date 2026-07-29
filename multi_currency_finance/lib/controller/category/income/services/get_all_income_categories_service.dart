import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/category/income/income_category.dart';
import 'package:multi_currency_finance/model/category/income/repository/income_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class GetAllIncomeCategoriesService implements IService<GetAllIncomeCategoriesRequest, GetAllIncomeCategoriesResponse> {
  final IIncomeCategoryRepository _incomeCategoryRepository;

  GetAllIncomeCategoriesService({
    required IIncomeCategoryRepository incomeCategoryRepository
  }) : 
  _incomeCategoryRepository = incomeCategoryRepository;

  @override
  Future<Result<GetAllIncomeCategoriesResponse>> execute(GetAllIncomeCategoriesRequest params) async {
    final categoriesResult = await _incomeCategoryRepository.findAll(params.page, params.perPage);

    if (categoriesResult.isError) return Result.failure(categoriesResult.error);

    return Result.success(GetAllIncomeCategoriesResponse(categories: categoriesResult.value));
  }
}

class GetAllIncomeCategoriesRequest {
  final int? page;
  final int? perPage;

  GetAllIncomeCategoriesRequest({
    this.page,
    this.perPage
  });
}

class GetAllIncomeCategoriesResponse {
  final List<IncomeCategory> categories;

  GetAllIncomeCategoriesResponse({
    required this.categories
  });
}