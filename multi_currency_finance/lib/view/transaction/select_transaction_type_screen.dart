import 'package:flutter/material.dart';

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
                    builder: (context) =>
                        const PlaceholderScreen(transactionType: 'Deposit'),
                  ),
                );
              },
              child: const Text('Deposit'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PlaceholderScreen(transactionType: 'Withdrawal'),
                  ),
                );
              },
              child: const Text('Withdrawal'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PlaceholderScreen(transactionType: 'Transfer'),
                  ),
                );
              },
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String transactionType;

  const PlaceholderScreen({super.key, required this.transactionType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$transactionType Selected')),
      body: Center(child: Text('$transactionType Selected')),
    );
  }
}
