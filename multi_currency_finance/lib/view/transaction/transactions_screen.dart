import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_currency_finance/controller/account/repository/memory_account_repository.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/controller/transaction/entities/transaction_data.dart';
import 'package:multi_currency_finance/controller/transaction/repository/memory_transaction_repository.dart';
import 'package:multi_currency_finance/controller/transaction/services/get_all_transactions_service.dart';
import 'package:multi_currency_finance/view/transaction/select_transaction_type_screen.dart';

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

  //Temp
  final IService<GetAllTransactionsRequest, GetAllTransactionsResponse> _getAllTransactionsService = GetAllTransactionsService(
    transactionRepository: MemoryTransactionRepository.instance, 
    accountRepository: MemoryAccountRepository.instance, 
    currencyRepository: MemoryCurrencyRepository.instance
  );

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newTransactionsResult = await _getAllTransactionsService.execute(
        GetAllTransactionsRequest(
          page: this._currentPage,
          perPage: this._perPage
        )
      );
      if (newTransactionsResult.isError) return;

      setState(() {
        _transactions.addAll(newTransactionsResult.value.transactions);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching transactions: $e');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _transactions.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _transactions.length) {
            final transaction = _transactions[index];
            final isExpanded = _expandedTransactions.contains(index);
            return Card(
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
                        'Type: ${transaction.type.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Date: ${transaction.date.toLocal().toString().split(' ')[0]}',
                      ),
                      const SizedBox(height: 4.0),
                      // Text('Currency: ${transaction.currencySymbol}'),
                      // const SizedBox(height: 4.0),
                      // Text('Description: ${transaction.description}'),
                      // const SizedBox(height: 4.0),
                      Text(
                        'Total: ${transaction.totalAmount.toStringAsFixed(2)}${transaction.currencySymbol} (${transaction.exchangedTotal.toStringAsFixed(2)})  ${transaction.description ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Balance Amounts:',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectTransactionTypeScreen(),
            ),
          ).then((result) {
            if (result == true) {
              _transactions.clear();
              _currentPage = 0;
              _loadTransactions();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
