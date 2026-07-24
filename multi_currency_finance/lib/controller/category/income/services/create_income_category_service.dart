import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/common/uuid/uuid_generator.dart';
import 'package:multi_currency_finance/model/category/income/income_category.dart';
import 'package:multi_currency_finance/model/category/income/repository/income_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class CreateIncomeCategoryService implements IService<CreateIncomeCategoryRequest, CreateIncomeCategoryResponse> {
  final IIncomeCategoryRepository _incomeCategoryRepository;

  CreateIncomeCategoryService({ required IIncomeCategoryRepository incomeCategoryRepository }) :
    _incomeCategoryRepository = incomeCategoryRepository;

  @override
  Future<Result<CreateIncomeCategoryResponse>> execute(CreateIncomeCategoryRequest params) async {
    final saveResult = await _incomeCategoryRepository.save(
      IncomeCategory(
        id: UuidGenerator.instance.v4(),
        name: params.categoryName
      )
    );

    if (saveResult.isError) return Result.failure(saveResult.error);

    return Result.success(CreateIncomeCategoryResponse(categoryId: saveResult.value));
  }

}

class CreateIncomeCategoryRequest {
  final String categoryName;

  CreateIncomeCategoryRequest({
    required this.categoryName
  });
}

class CreateIncomeCategoryResponse {
  final String categoryId;

  CreateIncomeCategoryResponse({
    required this.categoryId
  });
}