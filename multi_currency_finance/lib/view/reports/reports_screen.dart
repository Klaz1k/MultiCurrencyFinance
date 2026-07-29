import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/category/expense/repository/hive/hive_expense_category_repository.dart';
import 'package:multi_currency_finance/controller/category/income/repository/hive/hive_income_category_repository.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/transaction/entities/by_category_transaction_data.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_repository.dart';
import 'package:multi_currency_finance/controller/transaction/services/get_transactions_grouped_by_category_service.dart';
import 'package:multi_currency_finance/model/category/expense/expense_category.dart';
import 'package:multi_currency_finance/model/category/income/income_category.dart';

// ---------------------------------------------------------------------------
// Month label helper
// ---------------------------------------------------------------------------

const Map<int, String> _months = {
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December',
};

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  // ── Services ──────────────────────────────────────────────────────────────
  final IService<GetTransactionsGroupedByCategoryRequest,
          GetTransactionsGroupedByCategoryResponse>
      _service = GetTransactionsGroupedByCategoryService(
    transactionRepository: HiveTransactionRepository.instance,
    expenseCategoryRepository: HiveExpenseCategoryRepository.instance,
    incomeCategoryRepository: HiveIncomeCategoryRepository.instance,
  );

  // ── Date state ────────────────────────────────────────────────────────────
  int _selectedMonth = DateTime.now().month;
  late TextEditingController _yearController;

  // ── Data state ────────────────────────────────────────────────────────────
  bool _isLoading = false;
  GetTransactionsGroupedByCategoryResponse? _data;

  // ── Tab controller ────────────────────────────────────────────────────────
  late TabController _tabController;

  // ── Expanded-card tracking ────────────────────────────────────────────────
  final Set<String> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _yearController =
        TextEditingController(text: DateTime.now().year.toString());
    _fetchReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> _fetchReport() async {
    final year = int.tryParse(_yearController.text) ?? DateTime.now().year;
    setState(() {
      _isLoading = true;
      _expandedCards.clear();
    });

    final result = await _service.execute(
      GetTransactionsGroupedByCategoryRequest(
        date: DateTime(year, _selectedMonth),
      ),
    );

    if (!mounted) return;

    if (result.isError) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load report data.')),
      );
      return;
    }

    setState(() {
      _data = result.value;
      _isLoading = false;
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _toggleCard(String key) {
    setState(() {
      if (_expandedCards.contains(key)) {
        _expandedCards.remove(key);
      } else {
        _expandedCards.add(key);
      }
    });
  }

  double _sumExchanged(List<ByCategoryTransactionData> txns) =>
      txns.fold(0.0, (sum, t) => sum + t.exchangedTotal);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _fetchReport,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_down), text: 'Expenses'),
            Tab(icon: Icon(Icons.trending_up), text: 'Income'),
          ],
          indicatorColor: colorScheme.primary,
        ),
      ),
      body: Column(
        children: [
          // ── Date selectors ────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text(_months[i + 1] ?? ''),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedMonth = value);
                        _fetchReport();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _fetchReport(),
                  ),
                ),
              ],
            ),
          ),

          // ── Tab views ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildExpensesTab(),
                      _buildIncomeTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Expenses tab ──────────────────────────────────────────────────────────

  Widget _buildExpensesTab() {
    final data = _data;
    if (data == null) return _buildEmptyState('No report loaded yet.');

    final hasData =
        data.expenses.isNotEmpty || data.uncategorizedExpenses.isNotEmpty;
    if (!hasData) {
      return _buildEmptyState(
        'No expense data for ${_months[_selectedMonth]} ${_yearController.text}.',
      );
    }

    final items = <Widget>[];

    // Compute grand totals
    double grandExchanged = 0;
    for (final txns in data.expenses.values) {
      grandExchanged += _sumExchanged(txns);
    }
    grandExchanged += _sumExchanged(data.uncategorizedExpenses);

    items.add(_buildSummaryBanner(
      label: 'Total Expenses',
      total: grandExchanged,
      color: const Color(0xFFFFEBEB),
      textColor: const Color(0xFFD32F2F),
    ));

    // Category cards
    for (final entry in data.expenses.entries) {
      items.add(_buildExpenseCategoryCard(entry.key, entry.value));
    }

    // Uncategorized
    if (data.uncategorizedExpenses.isNotEmpty) {
      items.add(_buildUncategorizedCard(
        cardKey: 'expense-uncategorized',
        transactions: data.uncategorizedExpenses,
        color: const Color(0xFFFFF3E0),
        headerColor: const Color(0xFFE65100),
      ));
    }

    items.add(const SizedBox(height: 16));

    return RefreshIndicator(
      onRefresh: _fetchReport,
      child: ListView(padding: const EdgeInsets.only(top: 4), children: items),
    );
  }

  // ── Income tab ────────────────────────────────────────────────────────────

  Widget _buildIncomeTab() {
    final data = _data;
    if (data == null) return _buildEmptyState('No report loaded yet.');

    final hasData =
        data.incomes.isNotEmpty || data.uncategorizedIncomes.isNotEmpty;
    if (!hasData) {
      return _buildEmptyState(
        'No income data for ${_months[_selectedMonth]} ${_yearController.text}.',
      );
    }

    final items = <Widget>[];

    // Grand totals
    double grandExchanged = 0;
    for (final txns in data.incomes.values) {
      grandExchanged += _sumExchanged(txns);
    }
    grandExchanged += _sumExchanged(data.uncategorizedIncomes);

    items.add(_buildSummaryBanner(
      label: 'Total Income',
      total: grandExchanged,
      color: const Color(0xFFE8F5E9),
      textColor: const Color(0xFF1B5E20),
    ));

    // Category cards
    for (final entry in data.incomes.entries) {
      items.add(_buildIncomeCategoryCard(entry.key, entry.value));
    }

    // Uncategorized
    if (data.uncategorizedIncomes.isNotEmpty) {
      items.add(_buildUncategorizedCard(
        cardKey: 'income-uncategorized',
        transactions: data.uncategorizedIncomes,
        color: const Color(0xFFF3E5F5),
        headerColor: const Color(0xFF6A1B9A),
      ));
    }

    items.add(const SizedBox(height: 16));

    return RefreshIndicator(
      onRefresh: _fetchReport,
      child: ListView(padding: const EdgeInsets.only(top: 4), children: items),
    );
  }

  // ── Expense category card ─────────────────────────────────────────────────

  Widget _buildExpenseCategoryCard(
    ExpenseCategory category,
    List<ByCategoryTransactionData> transactions,
  ) {
    final cardKey = 'expense-${category.id}';
    final isExpanded = _expandedCards.contains(cardKey);

    final exchanged = _sumExchanged(transactions);

    return _buildCategoryCard(
      cardKey: cardKey,
      isExpanded: isExpanded,
      categoryName: category.name,
      transactionCount: transactions.length,
      exchanged: exchanged,
      transactions: transactions,
      cardColor: const Color(0xFFFFF5F5),
      headerAccent: const Color(0xFFD32F2F),
    );
  }

  // ── Income category card ──────────────────────────────────────────────────

  Widget _buildIncomeCategoryCard(
    IncomeCategory category,
    List<ByCategoryTransactionData> transactions,
  ) {
    final cardKey = 'income-${category.id}';
    final isExpanded = _expandedCards.contains(cardKey);
    final exchanged = _sumExchanged(transactions);

    return _buildCategoryCard(
      cardKey: cardKey,
      isExpanded: isExpanded,
      categoryName: category.name,
      transactionCount: transactions.length,
      exchanged: exchanged,
      transactions: transactions,
      cardColor: const Color(0xFFF1FBF1),
      headerAccent: const Color(0xFF2E7D32),
    );
  }

  // ── Uncategorized card ────────────────────────────────────────────────────

  Widget _buildUncategorizedCard({
    required String cardKey,
    required List<ByCategoryTransactionData> transactions,
    required Color color,
    required Color headerColor,
  }) {
    final isExpanded = _expandedCards.contains(cardKey);
    final exchanged = _sumExchanged(transactions);

    return _buildCategoryCard(
      cardKey: cardKey,
      isExpanded: isExpanded,
      categoryName: 'Uncategorized',
      transactionCount: transactions.length,
      exchanged: exchanged,
      transactions: transactions,
      cardColor: color,
      headerAccent: headerColor,
    );
  }

  // ── Shared category card ──────────────────────────────────────────────────

  Widget _buildCategoryCard({
    required String cardKey,
    required bool isExpanded,
    required String categoryName,
    required int transactionCount,
    required double exchanged,
    required List<ByCategoryTransactionData> transactions,
    required Color cardColor,
    required Color headerAccent,
  }) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggleCard(cardKey),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: headerAccent,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: headerAccent,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Summary row ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Exchanged: ${exchanged.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: headerAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ── Expanded detail ───────────────────────────────────────────
              if (isExpanded) ...[
                const Divider(height: 20),
                ...transactions.map((txn) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            txn.description ?? "Not Especified",
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            '${txn.totalAmount.toStringAsFixed(2)}  (${txn.exchangedTotal.toStringAsFixed(2)})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary banner ────────────────────────────────────────────────────────

  Widget _buildSummaryBanner({
    required String label,
    required double total,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: textColor,
            ),
          ),
          Text(
            total.toStringAsFixed(2),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
