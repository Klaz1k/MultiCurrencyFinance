import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/entities/account_data.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/delete_account_service.dart';
// import 'package:multi_currency_finance/controller/account/repository/memory_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/get_all_accounts_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_repository.dart';
// import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
// import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/view/account/create_account_screen.dart';
import 'package:multi_currency_finance/view/account/edit_account_screen.dart';

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
  final IService<GetAllAccountsRequest, GetAllAccountsResponse> _getAllAccountsService = GetAllAccountsService(
    accountRepository: HiveAccountRepository.instance, 
    currencyRepository: HiveCurrencyRepository.instance
  );

  final IService<DeleteAccountRequest, DeleteAccountResponse> _deleteAccountService = DeleteAccountService(accountRepository: HiveAccountRepository.instance);

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
      final newAccounts = await this._getAllAccountsService.execute(
        GetAllAccountsRequest(page: _currentPage, perPage: _perPage)
      );

      if (newAccounts.isError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newAccounts.error.runtimeType.toString()),
              duration: Durations.medium2,
            )
          );
        }
        return;
      }

      setState(() {
        _accounts.addAll(newAccounts.value.accounts);
        _currentPage++;
      });
    } catch (e) {
      print('Error fetching accounts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshAccounts() {
    _accounts.clear();
    _currentPage = 0; // Reset current page
    _loadMoreAccounts();
  }

  void _editAccount(AccountData account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAccountScreen(account: account),
      ),
    ).then((result) {
      if (result == true) {
        
        _refreshAccounts();
      }
    });
  }


  void _deleteAccount(AccountData account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Text('Are you sure you want to delete ${account.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();

                final deleteResult = await this._deleteAccountService.execute(DeleteAccountRequest(accountId: account.id));
                
                if (deleteResult.isError) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${account.name} could not be Deleted')),
                    );
                  }
                } else {
                  setState(() {
                    _accounts.removeWhere((a) => a.id == deleteResult.value.accountId);
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${account.name} Succesfully Deleted')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _accounts.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _accounts.length) {
            final account = _accounts[index];
            return AccountCard(
              account: account,
              onEdit: () => _editAccount(account),
              onDelete: () => _deleteAccount(account),
            );
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
              _refreshAccounts();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AccountCard extends StatefulWidget {
  final AccountData account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AccountCard({
    super.key, 
    required this.account,
    required this.onEdit,
    required this.onDelete
  });

  @override
  AccountCardState createState() => AccountCardState();
}

class AccountCardState extends State<AccountCard> {
  bool _isExpanded = false;

  void _showPopupMenu(BuildContext context, LongPressStartDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        overlay.size.width - details.globalPosition.dx,
        overlay.size.height - details.globalPosition.dy,
      ),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    ).then((String? value) {
      if (value == 'edit') {
        widget.onEdit();
      } else if (value == 'delete') {
        widget.onDelete();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => _showPopupMenu(context, details),
      child: Card(
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
                    children: widget.account.balance.balanceQueue.map((balanceAmount) => Text('Amount: ${balanceAmount.amount.toStringAsFixed(2)} at ${balanceAmount.exchangeRate.toStringAsFixed(2)} (${(balanceAmount.amount/balanceAmount.exchangeRate).toStringAsFixed(2)})')).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}