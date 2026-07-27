import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/transaction/entities/transaction_data.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_repository.dart';
import 'package:multi_currency_finance/controller/category/expense/repository/hive/hive_expense_category_repository.dart';
import 'package:multi_currency_finance/controller/category/income/repository/hive/hive_income_category_repository.dart';
import 'package:multi_currency_finance/controller/transaction/services/edit_transaction_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/category/expense/services/get_all_expense_categories_service.dart';
import 'package:multi_currency_finance/controller/category/income/services/get_all_income_categories_service.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionData transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  EditTransactionScreenState createState() => EditTransactionScreenState();
}

class EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;

  final IService<EditTrasactionRequest, EditTransactionResponse> _editTransactionService = EditTransactionService(
    transactionRepository: HiveTransactionRepository.instance,
    expenseCategoryRepository: HiveExpenseCategoryRepository.instance,
    incomeCategoryRepository: HiveIncomeCategoryRepository.instance,
  );

  bool _isLoadingInitialData = true;
  String? _selectedCategoryId;
  List<DropdownMenuItem<String?>> _categories = [];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {

    if (!mounted) return;
    
    _selectedCategoryId = widget.transaction.categoryId;

    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('No Category')),
    ];

    if (widget.transaction.type == TransactionType.Deposit) {
      final categoriesResult = await GetAllIncomeCategoriesService(incomeCategoryRepository: HiveIncomeCategoryRepository.instance)
          .execute(GetAllIncomeCategoriesRequest());
      if (!categoriesResult.isError) {
        items.addAll(categoriesResult.value.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))));
      }
    } else if (widget.transaction.type == TransactionType.Withdrawal) {
      final categoriesResult = await GetAllExpenseCategoriesService(expenseCategoryRepository: HiveExpenseCategoryRepository.instance)
          .execute(GetAllExpenseCategoriesRequest());
      if (!categoriesResult.isError) {
        items.addAll(categoriesResult.value.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))));
      }
    }

    _categories = items;

    if (!_categories.any((item) => item.value == _selectedCategoryId)) {
      _selectedCategoryId = null;
    }
    setState(() {
      _isLoadingInitialData = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final transactionEditResult = await this._editTransactionService.execute(
        EditTrasactionRequest(
          id: widget.transaction.id, 
          description: _descriptionController.text,
          categoryId: _selectedCategoryId,
        )
      );

      late final String snackBarText; 
      if (transactionEditResult.isError) {
        snackBarText = "Transaction Could not be Edited";
      } else {
        snackBarText = 'Transaction Succesfully Edited';
      }

      if (mounted) {
        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackBarText)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Transaction')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              if (widget.transaction.type == TransactionType.Deposit || widget.transaction.type == TransactionType.Withdrawal) ...[
                DropdownButtonFormField<String?>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category (Optional)',
                  ),
                  items: _categories,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
