import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/repository/memory_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/get_all_accounts_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/controller/transaction/repository/memory_transaction_repository.dart';
import 'package:multi_currency_finance/controller/transaction/services/make_transfer_service.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';

class MakeTransferScreen extends StatefulWidget {
  const MakeTransferScreen({super.key});

  @override
  State<MakeTransferScreen> createState() => _MakeTransferScreenState();
}

class _MakeTransferScreenState extends State<MakeTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _transferingAccountId;
  String? _receivingAccountId;
  final _outgoingAmountController = TextEditingController();
  final _incomingAmountController = TextEditingController();

  final IService<GetAllAccountsRequest, GetAllAccountsResponse> _getAllAccountsService = GetAllAccountsService(accountRepository: MemoryAccountRepository.instance, currencyRepository: MemoryCurrencyRepository.instance);
  final IService<MakeTransferRequest, MakeTransferResponse> _makeTrasferService = MakeTransferService(transactionRespository: MemoryTransactionRepository.instance, accountRepository: MemoryAccountRepository.instance, currencyRepository: MemoryCurrencyRepository.instance);

  @override
  void dispose() {
    _outgoingAmountController.dispose();
    _incomingAmountController.dispose();
    super.dispose();
  }

  void _submit() async {
    // Trigger validation on both dropdowns before submitting
    // _formKey.currentState!.validate();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // final request = MakeTransferRequest(
      //   transferingAccountId: _transferingAccountId!,
      //   receivingAccountId: _receivingAccountId!,
      //   outgoingAmount: double.parse(_outgoingAmountController.text),
      //   incomingAmount: double.parse(_incomingAmountController.text),
      // );
      await this._makeTrasferService.execute(
        MakeTransferRequest(
          transferingAccountId: _transferingAccountId!, 
          receivingAccountId: _receivingAccountId!, 
          outgoingAmount: double.parse(_outgoingAmountController.text), 
          incomingAmount: double.parse(_incomingAmountController.text)
        )
      );

      // Navigate to the transaction screen on success
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make a Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Result<GetAllAccountsResponse>>(
          future: this._getAllAccountsService.execute(GetAllAccountsRequest()),
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
            final accounts = snapshot.data!.value.accounts;
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    value: _transferingAccountId,
                    decoration: const InputDecoration(
                      labelText: 'From Account',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(
                          '${account.name} - \$${account.balance.getCurrentBalance().toStringAsFixed(2)}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _transferingAccountId = value;
                        // Re-validate the other dropdown when this one changes
                        _formKey.currentState?.validate();
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a transfering account.';
                      }
                      if (value == _receivingAccountId) {
                        return 'Cannot transfer to the same account.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _receivingAccountId,
                    decoration: const InputDecoration(
                      labelText: 'To Account',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(
                          '${account.name} - \$${account.balance.getCurrentBalance().toStringAsFixed(2)}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _receivingAccountId = value;
                        // Re-validate the other dropdown when this one changes
                        _formKey.currentState?.validate();
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a receiving account.';
                      }
                      if (value == _transferingAccountId) {
                        return 'Cannot receive from the same account.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _outgoingAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Outgoing Amount',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount.';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Please enter a valid number.';
                      }
                      if (amount <= 0) {
                        return 'Amount must be greater than zero.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _incomingAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Incoming Amount',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount.';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Please enter a valid number.';
                      }
                      if (amount <= 0) {
                        return 'Amount must be greater than zero.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Confirm Transfer'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
