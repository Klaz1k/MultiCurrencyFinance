import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
// import 'package:multi_currency_finance/controller/account/repository/memory_account_repository.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_repository.dart';
// import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/controller/transaction/entities/transaction_data.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_repository.dart';
// import 'package:multi_currency_finance/controller/transaction/repository/memory_transaction_repository.dart';
import 'package:multi_currency_finance/controller/transaction/services/get_transactions_by_date_service.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';
import 'package:multi_currency_finance/view/transaction/select_transaction_type_screen.dart';

final Map<int, String> _months = {
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

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  TransactionsScreenState createState() => TransactionsScreenState();
}

class TransactionsScreenState extends State<TransactionsScreen> {
  final List<TransactionData> _transactions = [];
  int _currentPage = 0;
  final int _perPage = 10;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final Set<int> _expandedTransactions = {};

  int _selectedMonth = DateTime.now().month;
  late TextEditingController _yearController;

  //Temp
  final IService<GetTransactionsByDateRequest, GetTransactionsByDateResponse> _getTransactionsByDateService = GetTransactionsByDateService(
    transactionRepository: HiveTransactionRepository.instance, 
    accountRepository: HiveAccountRepository.instance, 
    currencyRepository: HiveCurrencyRepository.instance
  );

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: DateTime.now().year.toString());
    _loadTransactions();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.Deposit:
        return const Color.fromARGB(145, 105, 240, 175);

      case TransactionType.Withdrawal:
        return const Color.fromARGB(145, 255, 82, 82);

      case TransactionType.IncomingTransfer:
        return const Color.fromARGB(145, 64, 195, 255);
      
      case TransactionType.OutgoingTransfer:
        return const Color.fromARGB(145, 64, 195, 255);
    }
  }

  Future<void> _loadTransactions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newTransactionsResult = await _getTransactionsByDateService.execute(
        GetTransactionsByDateRequest(
          page: this._currentPage,
          perPage: this._perPage,
          monthAsNumber: _selectedMonth,
          year: int.tryParse(_yearController.text) ?? DateTime.now().year
        )
      );
      if (newTransactionsResult.isError) return;

      setState(() {
        _transactions.addAll(newTransactionsResult.value.transactions);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedTransactions.contains(index)) {
        _expandedTransactions.remove(index);
      } else {
        _expandedTransactions.add(index);
      }
    });
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _transactions.clear();
      _currentPage = 0;
      _expandedTransactions.clear();
    });
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(_months[index + 1] ?? ''),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                        });

                        _refreshTransactions();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _refreshTransactions(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _transactions.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _transactions.length) {
                  final transaction = _transactions[index];
                  final isExpanded = _expandedTransactions.contains(index);
                  return Card(
                    color: _getTransactionTypeColor(_transactions[index].type),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: InkWell(
                      onTap: () => _toggleExpand(index),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.type.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Date: ${transaction.date.toLocal().toString().split(' ')[0]}',
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Total: ${transaction.totalAmount.toStringAsFixed(2)}${transaction.currencySymbol} (${transaction.exchangedTotal.toStringAsFixed(2)})  ${transaction.description}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Balance Amounts:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ...transaction.balanceList.map(
                                      (ba) => Text(
                                        'Amount: ${ba.amount.toStringAsFixed(2)}, Rate: ${ba.exchangeRate.toStringAsFixed(2)}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectTransactionTypeScreen(),
            ),
          ).then((result) {
            if (result == true) {
              _refreshTransactions();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
