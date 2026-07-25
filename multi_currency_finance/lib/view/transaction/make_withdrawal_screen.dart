import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/entities/account_data.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
// import 'package:multi_currency_finance/controller/account/repository/memory_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/get_all_accounts_service.dart';
import 'package:multi_currency_finance/controller/category/expense/repository/hive/hive_expense_category_repository.dart';
import 'package:multi_currency_finance/controller/category/expense/services/get_all_expense_categories_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_repository.dart';
// import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_repository.dart';
// import 'package:multi_currency_finance/controller/transaction/repository/memory_transaction_repository.dart';
import 'package:multi_currency_finance/controller/transaction/services/make_withdrawal_service.dart';
import 'package:multi_currency_finance/model/category/expense/expense_category.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/view/category/create_expense_category_screen.dart';

// --- Screen Widget ---

class MakeWithdrawalScreen extends StatefulWidget {
  const MakeWithdrawalScreen({super.key});

  @override
  State<MakeWithdrawalScreen> createState() => _MakeWithdrawalScreenState();
}

class _MakeWithdrawalScreenState extends State<MakeWithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  final IService<GetAllAccountsRequest, GetAllAccountsResponse>
  _getAllAccountsService = GetAllAccountsService(
    accountRepository: HiveAccountRepository.instance,
    currencyRepository: HiveCurrencyRepository.instance,
  );

  final IService<GetAllExpenseCategoriesRequest,
          GetAllExpenseCategoriesResponse>
  _getAllExpenseCategoriesService = GetAllExpenseCategoriesService(
    expenseCategoryRepository: HiveExpenseCategoryRepository.instance,
  );

  final IService<MakeWithdrawalRequest, MakeWithdrawalResponse>
  _makeWithdrawalService = MakeWithdrawalService(
    transactionRepository: HiveTransactionRepository.instance,
    accountRepository: HiveAccountRepository.instance,
  );

  late Future<Result<GetAllAccountsResponse>> _accountsFuture;
  List<ExpenseCategory> _categories = [];
  bool _isLoadingCategories = true;

  String? _selectedAccountId;
  AccountData? _selectedAccount; // New state variable for selected account data
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _accountsFuture = _getAllAccountsService.execute(GetAllAccountsRequest());
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    final result = await _getAllExpenseCategoriesService
        .execute(GetAllExpenseCategoriesRequest());
    if (!mounted) return;
    if (result.isError) {
      setState(() => _isLoadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load expense categories.')),
      );
      return;
    }
    setState(() {
      _categories = result.value.categories;
      _isLoadingCategories = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await _makeWithdrawalService.execute(
        MakeWithdrawalRequest(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          description: _descriptionController.text.trim(),
          amount: double.parse(_amountController.text),
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make a Withdrawal')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Account Dropdown
                _buildAccountDropdown(),
                const SizedBox(height: 16),

                // Display current balance if an account is selected
                if (_selectedAccount != null) ...[
                  Text(
                    'Current Balance: ${_selectedAccount?.currencySymbol}${_selectedAccount!.balance.getCurrentBalance().toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                ],

                // Category Dropdown
                _buildCategoryDropdown(),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Please enter a valid number';
                    }
                    if (number <= 0) {
                      // Changed from positive to greater than zero
                      return 'Amount must be greater than zero';
                    }
                    if (_selectedAccount != null &&
                        number >
                            _selectedAccount!.balance.getCurrentBalance()) {
                      return 'Amount exceeds current balance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Make Withdrawal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDropdown() {
    return FutureBuilder<Result<GetAllAccountsResponse>>(
      future: _accountsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Unexpected Error'));
        }
        if (snapshot.data!.isError) {
          return Center(child: Text('Error: ${snapshot.data!.error}'));
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedAccountId,
          decoration: const InputDecoration(
            labelText: 'Account',
            border: OutlineInputBorder(),
          ),
          hint: const Text('Select an account'),
          items: snapshot.data!.value.accounts.map((account) {
            return DropdownMenuItem<String>(
              value: account.id,
              child: Text(account.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAccountId = value;
              // Find the selected account object
              _selectedAccount = snapshot.data!.value.accounts.firstWhere(
                (account) => account.id == value,
              );
            });
          },
          validator: (value) =>
              value == null ? 'Please select an account' : null,
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = [
      const DropdownMenuItem<String>(value: null, child: Text('No Category')),
      ..._categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        );
      }),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'Category (Optional)',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Select a category'),
            items: items,
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Create new expense category',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateExpenseCategoryScreen(),
              ),
            ).then((result) {
              if (result == true) {
                _fetchCategories();
              }
            });
          },
        ),
      ],
    );
  }
}
