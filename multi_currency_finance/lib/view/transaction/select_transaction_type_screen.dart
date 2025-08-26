import 'package:flutter/material.dart';
import 'package:multi_currency_finance/view/transaction/make_deposit_screen.dart';
import 'package:multi_currency_finance/view/transaction/make_transfer_screen.dart';
import 'package:multi_currency_finance/view/transaction/make_withdrawal_screen.dart';

class SelectTransactionTypeScreen extends StatelessWidget {
  const SelectTransactionTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Transaction Type')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakeDepositScreen(),
                  ),
                ).then((result) {
                  if (result == true && context.mounted) Navigator.pop(context, true);
                });
              },
              child: const Text('Deposit'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakeWithdrawalScreen()
                  ),
                ).then((result) {
                  if (result == true && context.mounted) Navigator.pop(context, true); 
                });
              },
              child: const Text('Withdrawal'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakeTransferScreen()
                  ),
                ).then((result) {
                  if (result == true && context.mounted) Navigator.pop(context, true);
                });
              },
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
