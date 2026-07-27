import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/model/category/expense/repository/expense_category_repository.interface.dart';
import 'package:multi_currency_finance/model/category/income/repository/income_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';

class EditTransactionService implements IService<EditTrasactionRequest, EditTransactionResponse> {
  final ITransactionRepository _transactionRepository;
  final IExpenseCategoryRepository _expenseCategoryRepository;
  final IIncomeCategoryRepository _incomeCategoryRepository;

  EditTransactionService({
    required ITransactionRepository transactionRepository,
    required IExpenseCategoryRepository expenseCategoryRepository,
    required IIncomeCategoryRepository incomeCategoryRepository
  }) : 
    _transactionRepository = transactionRepository,
    _expenseCategoryRepository = expenseCategoryRepository,
    _incomeCategoryRepository = incomeCategoryRepository;

  @override
  Future<Result<EditTransactionResponse>> execute(EditTrasactionRequest params) async {
    final transactionResult = await _transactionRepository.findById(params.id);

    if (transactionResult.isError) return Result.failure(transactionResult.error);

    if (params.categoryId != null) {
      switch (transactionResult.value.transactionType) {
        case TransactionType.Deposit:
          final incomeCategoryResult = await _incomeCategoryRepository.findById(params.categoryId!);

          if (incomeCategoryResult.isError) return Result.failure(incomeCategoryResult.error);
          break;

        case TransactionType.Withdrawal:
          final expenseCategoryResult = await _expenseCategoryRepository.findById(params.categoryId!);

          if (expenseCategoryResult.isError) return Result.failure(expenseCategoryResult.error);
          break;

        default: break;
      }
    }

    transactionResult.value.categoryId = params.categoryId;
    transactionResult.value.description = params.description;

    final saveResult = await _transactionRepository.save(transactionResult.value);

    if (saveResult.isError) return Result.failure(saveResult.error);

    return Result.success(
      EditTransactionResponse(id: saveResult.value)
    );
  }

}

class EditTrasactionRequest {
  final String id;
  final String? categoryId;
  final String? description;

  EditTrasactionRequest({
    required this.id,
    this.categoryId,
    this.description
  });
}

class EditTransactionResponse {
  final String id;

  EditTransactionResponse({
    required this.id
  });
}