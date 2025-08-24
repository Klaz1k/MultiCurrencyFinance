import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/entities/account_data.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
// import 'package:multi_currency_finance/controller/account/repository/memory_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/get_all_accounts_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_repository.dart';
// import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
// import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/view/account/create_account_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  AccountsScreenState createState() => AccountsScreenState();
}

class AccountsScreenState extends State<AccountsScreen> {
  final List<AccountData> _accounts = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _perPage = 10; // Number of accounts to fetch per page

  //Temp
  final IService<GetAllAccountsRequest, GetAllAccountsResponse> getAllAccountsService = GetAllAccountsService(
    accountRepository: HiveAccountRepository.instance, 
    currencyRepository: HiveCurrencyRepository.instance
  );

  @override
  void initState() {
    super.initState();
    _loadMoreAccounts(); // Load initial data
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _loadMoreAccounts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreAccounts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newAccounts = await this.getAllAccountsService.execute(
        GetAllAccountsRequest(page: _currentPage, perPage: _perPage)
      );

      if (newAccounts.isError) return;

      setState(() {
        _accounts.addAll(newAccounts.value.accounts);
        _currentPage++;
      });
    } catch (e) {
      print('Error fetching accounts: $e');
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _accounts.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {if (index < _accounts.length) {
          final account = _accounts[index];return AccountCard(account: account);
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAccountScreen()),
          ).then((result) {
            if (result == true) {
              // Account created successfully, refresh the list
              _accounts.clear();
              _currentPage = 0; // Reset current page
              _loadMoreAccounts();
            }
          });
        },
        child: const Icon(Icons.add)),
    );
  }
}

class AccountCard extends StatefulWidget {
  final AccountData account;

  const AccountCard({super.key, required this.account});

  @override
  AccountCardState createState() => AccountCardState();
}

class AccountCardState extends State<AccountCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          children: [
            ListTile(
              title: Text(widget.account.name),
              trailing: Text(
                '${widget.account.currencySymbol}${widget.account.balance.getCurrentBalance().toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.account.balance.balanceQueue.map((balanceAmount) => Text('Amount: ${balanceAmount.amount.toStringAsFixed(2)} (${(balanceAmount.amount/balanceAmount.exchangeRate).toStringAsFixed(2)})')).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}