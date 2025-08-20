import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/entities/account_data.dart';
import 'package:multi_currency_finance/controller/account/repository/memory_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/get_all_accounts_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/controller/transaction/repository/memory_transaction_repository.dart';
import 'package:multi_currency_finance/controller/transaction/services/make_withdrawal_service.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

// --- Data Models ---

class CategoryData {
  final String id;
  final String name;

  CategoryData({required this.id, required this.name});
}

// --- Mock Services ---

class MockCategoryService {
  Future<List<CategoryData>> getCategories() async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simulate network delay
    return [];
  }
}

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

  final _categoryService = MockCategoryService();

  final IService<GetAllAccountsRequest, GetAllAccountsResponse> _getAllAccountsService = GetAllAccountsService(accountRepository: MemoryAccountRepository.instance, currencyRepository: MemoryCurrencyRepository.instance);
  final IService<MakeWithdrawalRequest, MakeWithdrawalResponse> _makeWithdrawalService = MakeWithdrawalService(transactionRepository: MemoryTransactionRepository.instance, accountRepository: MemoryAccountRepository.instance);

  late Future<Result<GetAllAccountsResponse>> _accountsFuture;
  late Future<List<CategoryData>> _categoriesFuture;

  String? _selectedAccountId;
  AccountData? _selectedAccount; // New state variable for selected account data
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _accountsFuture = _getAllAccountsService.execute(GetAllAccountsRequest());
    _categoriesFuture = _categoryService.getCategories();
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

      await this._makeWithdrawalService.execute(
        MakeWithdrawalRequest(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId, 
          description: _descriptionController.text.trim(),
          amount: double.parse(_amountController.text)
        )
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
                    'Current Balance: ${_selectedAccount!.currencySymbol}${_selectedAccount!.balance.getCurrentBalance().toStringAsFixed(2)}',
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
                        number > _selectedAccount!.balance.getCurrentBalance()) {
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
          value: _selectedAccountId,
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
    return FutureBuilder<List<CategoryData>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('No Category'),
          ),
          if (snapshot.hasData)
            ...snapshot.data!.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              );
            }),
        ];

        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
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
        );
      },
    );
  }
}
