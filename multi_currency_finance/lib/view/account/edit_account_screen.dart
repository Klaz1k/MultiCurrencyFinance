import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/entities/account_data.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/edit_account_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';

class EditAccountScreen extends StatefulWidget {
  final AccountData account;

  const EditAccountScreen({super.key, required this.account});

  @override
  EditAccountScreenState createState() => EditAccountScreenState();
}

class EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _accountNameController;
  late TextEditingController _descriptionController;

  final IService<EditAccountRequest, EditAccountResponse> _editAccountService = EditAccountService(accountRepository: HiveAccountRepository.instance);

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController(text: widget.account.name);
    _descriptionController = TextEditingController(text: widget.account.description);
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would call a service to update the account's name and description.
      // print('Updating Account Name to: ${_accountNameController.text}');
      // print('Updating Account Description to: ${_descriptionController.text}');

      final accountEditResult = await this._editAccountService.execute(
        EditAccountRequest(
          accountId: widget.account.id, 
          accountName: _accountNameController.text,
          accountDescription: _descriptionController.text
        )
      );

      late final String snackBarText; 
      if (accountEditResult.isError) {
        snackBarText = "${widget.account.name} Could not be Edited";
      } else {
        snackBarText = '${widget.account.name} Succesfully Edited';
      }

      // Simulate update and pop
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
