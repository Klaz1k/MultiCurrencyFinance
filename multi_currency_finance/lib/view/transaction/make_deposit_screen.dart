import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
// import 'package:multi_currency_finance/controller/account/repository/memory_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/get_all_accounts_service.dart';
import 'package:multi_currency_finance/controller/category/income/repository/hive/hive_income_category_repository.dart';
import 'package:multi_currency_finance/controller/category/income/services/get_all_income_categories_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_repository.dart';
// import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_repository.dart';
// import 'package:multi_currency_finance/controller/transaction/repository/memory_transaction_repository.dart';
import 'package:multi_currency_finance/controller/transaction/services/make_deposit_service.dart';
import 'package:multi_currency_finance/model/category/income/income_category.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/view/category/create_income_category_screen.dart';

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
  final _mainCurrencyEquivalentController = TextEditingController(text: '1.0');

  final IService<GetAllAccountsRequest, GetAllAccountsResponse>
  _getAllAccountsService = GetAllAccountsService(
    accountRepository: HiveAccountRepository.instance,
    currencyRepository: HiveCurrencyRepository.instance,
  );

  final IService<GetAllIncomeCategoriesRequest, GetAllIncomeCategoriesResponse>
  _getAllIncomeCategoriesService = GetAllIncomeCategoriesService(
    incomeCategoryRepository: HiveIncomeCategoryRepository.instance,
  );

  final IService<MakeDepositRequest, MakeDepositResponse>
  _makeDepositService = MakeDepositService(
    transactionRepository: HiveTransactionRepository.instance,
    accountRepository: HiveAccountRepository.instance,
  );

  late Future<Result<GetAllAccountsResponse>> _accountsFuture;
  List<IncomeCategory> _categories = [];
  bool _isLoadingCategories = true;

  String? _selectedAccountId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _accountsFuture = _getAllAccountsService.execute(GetAllAccountsRequest());
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    final result = await _getAllIncomeCategoriesService
        .execute(GetAllIncomeCategoriesRequest());
    if (!mounted) return;
    if (result.isError) {
      setState(() => _isLoadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load income categories.')),
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
    _mainCurrencyEquivalentController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print(_selectedCategoryId);
      await _makeDepositService.execute(
        MakeDepositRequest(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          description: _descriptionController.text.trim(),
          amountDeposited: double.parse(_amountController.text),
          mainCurrencyEquivalent:
              double.parse(_mainCurrencyEquivalentController.text),
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
                  controller: _mainCurrencyEquivalentController,
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
          tooltip: 'Create new income category',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateIncomeCategoryScreen(),
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
