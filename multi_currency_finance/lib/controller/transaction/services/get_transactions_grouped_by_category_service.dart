import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/transaction/entities/by_category_transaction_data.dart';
import 'package:multi_currency_finance/model/category/expense/expense_category.dart';
import 'package:multi_currency_finance/model/category/expense/repository/expense_category_repository.interface.dart';
import 'package:multi_currency_finance/model/category/income/income_category.dart';
import 'package:multi_currency_finance/model/category/income/repository/income_category_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';

class GetTransactionsGroupedByCategoryService implements IService<GetTransactionsGroupedByCategoryRequest, GetTransactionsGroupedByCategoryResponse> {
  final ITransactionRepository _transactionRepository;
  final IExpenseCategoryRepository _expenseCategoryRepository;
  final IIncomeCategoryRepository _incomeCategoryRepository;

  GetTransactionsGroupedByCategoryService({
    required ITransactionRepository transactionRepository,
    required IExpenseCategoryRepository expenseCategoryRepository,
    required IIncomeCategoryRepository incomeCategoryRepository
  }) :
    _transactionRepository = transactionRepository,
    _expenseCategoryRepository = expenseCategoryRepository,
    _incomeCategoryRepository = incomeCategoryRepository;

  @override
  Future<Result<GetTransactionsGroupedByCategoryResponse>> execute(GetTransactionsGroupedByCategoryRequest params) async {
    final Map<ExpenseCategory, List<ByCategoryTransactionData>> expenses = {};
    List<ByCategoryTransactionData> uncategorizedExpenses = [];
    final Map<IncomeCategory, List<ByCategoryTransactionData>> incomes = {};
    List<ByCategoryTransactionData> uncategorizedIncomes = [];

    final groupedExpensesResult = await _transactionRepository.findExpensesByDateGroupedByCategory(params.date.month, params.date.year);

    if (!groupedExpensesResult.isError) {
      groupedExpensesResult.value.forEach((categoryId, transactions) async {
        final transactionsMapIterable = transactions.map((transaction) => ByCategoryTransactionData(id: transaction.id, type: transaction.transactionType, description: transaction.description, balanceList: transaction.transactedAmount, totalAmount: transaction.getTotalTransacted(), exchangedTotal: transaction.getExchangedTotal()));
        
        if (categoryId == "") {
          uncategorizedExpenses = transactionsMapIterable.toList();
          return;
        }

        final categoryResult = await _expenseCategoryRepository.findById(categoryId);

        if (categoryResult.isError) return;

        expenses[categoryResult.value] = transactionsMapIterable.toList();
      });
    }

    final groupedIncomeResult = await _transactionRepository.findIncomeByDateGroupedByCategory(params.date.month, params.date.year);

    if (!groupedIncomeResult.isError) {
      groupedIncomeResult.value.forEach((categoryId, transactions) async {
        final transactionsMapIterable = transactions.map((transaction) => ByCategoryTransactionData(id: transaction.id, type: transaction.transactionType, description: transaction.description, balanceList: transaction.transactedAmount, totalAmount: transaction.getTotalTransacted(), exchangedTotal: transaction.getExchangedTotal()));
        
        if (categoryId == "") {
          uncategorizedIncomes = transactionsMapIterable.toList();
          return;
        }

        final categoryResult = await _incomeCategoryRepository.findById(categoryId);

        if (categoryResult.isError) return;

        incomes[categoryResult.value] = transactionsMapIterable.toList();
      });
    }

    return Result.success(
      GetTransactionsGroupedByCategoryResponse(
        expenses: expenses,
        uncategorizedExpenses: uncategorizedExpenses,
        incomes: incomes,
        uncategorizedIncomes: uncategorizedIncomes
      )
    );
  }
}

class GetTransactionsGroupedByCategoryRequest {
  final DateTime date;

  GetTransactionsGroupedByCategoryRequest({
    required this.date
  });
}

class GetTransactionsGroupedByCategoryResponse {
  final Map<ExpenseCategory, List<ByCategoryTransactionData>> expenses;
  final List<ByCategoryTransactionData> uncategorizedExpenses;
  final Map<IncomeCategory, List<ByCategoryTransactionData>> incomes;
  final List<ByCategoryTransactionData> uncategorizedIncomes;

  GetTransactionsGroupedByCategoryResponse({
    required this.expenses,
    required this.uncategorizedExpenses,
    required this.incomes,
    required this.uncategorizedIncomes
  });
}