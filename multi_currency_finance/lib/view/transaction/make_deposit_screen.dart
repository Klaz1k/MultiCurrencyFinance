import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
// import 'package:multi_currency_finance/controller/account/repository/memory_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/get_all_accounts_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_repository.dart';
// import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_repository.dart';
// import 'package:multi_currency_finance/controller/transaction/repository/memory_transaction_repository.dart';
import 'package:multi_currency_finance/controller/transaction/services/make_deposit_service.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';


// Temp data for Categories

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
    return []; // For now, lets just reflect the "No Category" option
  }
}
// --- Screen Widget ---

class MakeDepositScreen extends StatefulWidget {
  const MakeDepositScreen({super.key});

  @override
  State<MakeDepositScreen> createState() => _MakeDepositScreenState();
}

class _MakeDepositScreenState extends State<MakeDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _exchangeRateController = TextEditingController(text: '1.0');

  // final _accountService = MockAccountService();
  final _categoryService = MockCategoryService();

  final IService<GetAllAccountsRequest, GetAllAccountsResponse> _getAllAccountsService = GetAllAccountsService(
    accountRepository: HiveAccountRepository.instance, 
    currencyRepository: HiveCurrencyRepository.instance
  );

  final IService<MakeDepositRequest, MakeDepositResponse> _makeDepositService = MakeDepositService(
    transactionRepository: HiveTransactionRepository.instance, 
    accountRepository: HiveAccountRepository.instance
  );
  
  late Future<Result<GetAllAccountsResponse>> _accountsFuture;
  late Future<List<CategoryData>> _categoriesFuture;

  String? _selectedAccountId;
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
    _exchangeRateController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // final depositRequest = MakeDepositRequest(
      //   accountId: _selectedAccountId!,
      //   categoryId: _selectedCategoryId,
      //   description: _descriptionController.text.trim(),
      //   amount: double.parse(_amountController.text),
      //   exchangeRate: double.parse(_exchangeRateController.text),
      // );

      await this._makeDepositService.execute(
        MakeDepositRequest(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          description: _descriptionController.text.trim(),
          amountDeposited: double.parse(_amountController.text), 
          mainCurrencyEquivalent: double.parse(_exchangeRateController.text)
        )
      );

      // ignore: avoid_print
      // print('Submitting Deposit: $depositRequest');

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make a Deposit')),
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
                      return 'Amount must be positive';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Exchange Rate
                TextFormField(
                  controller: _exchangeRateController,
                  decoration: const InputDecoration(
                    labelText: 'Main Currency Equivalent',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_exchange),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an equivalent';
                    }
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Please enter a valid number';
                    }
                    if (number <= 0) {
                      return 'Equivalent must be positive';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Make Deposit'),
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
