import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/category/income/repository/hive/hive_income_category_repository.dart';
import 'package:multi_currency_finance/controller/category/income/services/create_income_category_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';

class CreateIncomeCategoryScreen extends StatefulWidget {
  const CreateIncomeCategoryScreen({super.key});

  @override
  State<CreateIncomeCategoryScreen> createState() =>
      _CreateIncomeCategoryScreenState();
}

class _CreateIncomeCategoryScreenState
    extends State<CreateIncomeCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  bool _isSubmitting = false;

  final IService<CreateIncomeCategoryRequest, CreateIncomeCategoryResponse>
  _createIncomeCategoryService = CreateIncomeCategoryService(
    incomeCategoryRepository: HiveIncomeCategoryRepository.instance,
  );

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final result = await _createIncomeCategoryService.execute(
        CreateIncomeCategoryRequest(
          categoryName: _categoryNameController.text.trim(),
        ),
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (result.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create income category.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Income category created successfully.'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Income Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Income Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
