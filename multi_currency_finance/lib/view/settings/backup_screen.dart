import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
import 'package:multi_currency_finance/controller/backup/services/get_backup_data_service.dart';
import 'package:multi_currency_finance/controller/category/expense/repository/hive/hive_expense_category_repository.dart';
import 'package:multi_currency_finance/controller/category/income/repository/hive/hive_income_category_repository.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_repository.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_repository.dart';
import 'package:path_provider/path_provider.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  BackupScreenState createState() => BackupScreenState();
}

class BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;

  String? _currenciesStatus;
  String? _accountsStatus;
  String? _transactionsStatus;
  String? _expenseCategoriesStatus;
  String? _incomeCategoriesStatus;

  bool _currenciesSuccess = false;
  bool _accountsSuccess = false;
  bool _transactionsSuccess = false;
  bool _expenseCategoriesSuccess = false;
  bool _incomeCategoriesSuccess = false;

  final IService<GetBackupDataRequest, GetBackupDataResponse> _getBackupDataService = GetBackupDataService(
    currencyRepository: HiveCurrencyRepository.instance,
    accountRepository: HiveAccountRepository.instance,
    transactionRepository: HiveTransactionRepository.instance,
    expenseCategoryRepository: HiveExpenseCategoryRepository.instance,
    incomeCategoryRepository: HiveIncomeCategoryRepository.instance
  );

  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
      _currenciesStatus = null;
      _accountsStatus = null;
      _transactionsStatus = null;
      _expenseCategoriesStatus = null;
      _incomeCategoriesStatus = null;

      _currenciesSuccess = false;
      _accountsSuccess = false;
      _transactionsSuccess = false;
      _expenseCategoriesSuccess = false;
      _incomeCategoriesSuccess = false;
    });

    final result = await _getBackupDataService.execute(GetBackupDataRequest());

    if (result.isError) {
      setState(() {
        _isLoading = false;
        _currenciesStatus = 'Failed to load data from database.';
        _accountsStatus = 'Failed to load data from database.';
        _transactionsStatus = 'Failed to load data from database.';
        _expenseCategoriesStatus = 'Failed to load data from database.';
        _incomeCategoriesStatus = 'Failed to load data from database.';
      });
      return;
    }

    final data = result.value;

    final currenciesJson = const JsonEncoder.withIndent('  ')
        .convert(data.currencies.map((c) => c.toJson()).toList());

    final accountsJson = const JsonEncoder.withIndent('  ')
        .convert(data.accounts.map((a) => a.toJson()).toList());

    final transactionsJson = const JsonEncoder.withIndent('  ')
        .convert(data.transactions.map((t) => t.toJson()).toList());
    
    final expenseCategoriesJson = const JsonEncoder.withIndent('  ')
        .convert(data.expenseCategories.map((t) => t.toJson()).toList());

    final incomeCategoriesJson = const JsonEncoder.withIndent('  ')
        .convert(data.incomeCategories.map((t) => t.toJson()).toList());



    try {
      // final path = await FilePicker.getDirectoryPath(
      //   dialogTitle: 'Pick location for backup files',
      //   lockParentWindow: true
      // );

      final directory = await getDownloadsDirectory();

      if (directory == null) {
          setState(() {
          _isLoading = false;
          _currenciesStatus = 'Error: Could not find Downloads folder path';
          _accountsStatus = 'Error: Could not find Downloads folder path';
          _transactionsStatus = 'Error: Could not find Downloads folder path';
          _expenseCategoriesStatus = 'Error: Could not find Downloads folder path';
          _incomeCategoriesStatus = 'Error: Could not find Downloads folder path';
        });
        return;
      }

      final path = "${directory.path}/MultiCurrencyBackups";

      // if (path == null) {
      //   setState(() {
      //     _currenciesStatus = 'Save cancelled.';
      //     _accountsStatus = 'Save cancelled.';
      //     _transactionsStatus = 'Save cancelled.';
      //     _isLoading = false;
      //   });
      //   return;
      // }

      await _saveJsonFile(
        fileName: 'currencies.json',
        path: path,
        content: currenciesJson,
        onSuccess: (file) => setState(() {
          _currenciesStatus = 'Saved to ${file.path}';
          _currenciesSuccess = true;
        })
      );

      await _saveJsonFile(
        fileName: 'accounts.json',
        path: path,
        content: accountsJson,
        onSuccess: (file) => setState(() {
          _accountsStatus = 'Saved to ${file.path}';
          _accountsSuccess = true;
        })
      );

      await _saveJsonFile(
        fileName: 'transactions.json',
        path: path,
        content: transactionsJson,
        onSuccess: (file) => setState(() {
          _transactionsStatus = 'Saved to ${file.path}';
          _transactionsSuccess = true;
        })
      );

      await _saveJsonFile(
        fileName: 'expenseCategories.json', 
        path: path, 
        content: expenseCategoriesJson, 
        onSuccess: (file) => setState(() {
          _expenseCategoriesStatus = 'Saved to ${file.path}';
          _expenseCategoriesSuccess = true;
        })
      );

      await _saveJsonFile(
        fileName: 'incomeCategories.json', 
        path: path, 
        content: incomeCategoriesJson, 
        onSuccess: (file) => setState(() {
          _incomeCategoriesStatus = 'Saved to ${file.path}';
          _incomeCategoriesSuccess = true;
        })
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _currenciesStatus = 'Error: $e';
        _accountsStatus = 'Error: $e';
        _transactionsStatus = 'Error: $e';
        _expenseCategoriesStatus = 'Error: $e';
        _incomeCategoriesStatus = 'Error: $e';
      });
      return;
    }
  }

  Future<void> _saveJsonFile({
    required String fileName,
    required String path,
    required String content,
    required Function(File file) onSuccess
  }) async {
    try {
      // final bytes = utf8.encode(content);
      
      final file = File('$path/$fileName');

      await file.parent.create(recursive: true);

      final writtenFile = await file.writeAsString(content);

      onSuccess(writtenFile);
      // final path = await FilePicker.saveFile(
      //   dialogTitle: 'Save $fileName',
      //   fileName: fileName,
      //   type: FileType.custom,
      //   allowedExtensions: ['json'],
      //   bytes: bytes,
      // );

    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Data'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Card(
              elevation: 0,
              color: colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.backup_rounded,
                      size: 48,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create a Backup',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Backup the current state of the database as '
                      'JSON files to a location of your choice.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status cards — only shown after a backup attempt
            if (_currenciesStatus != null ||
                _accountsStatus != null ||
                _transactionsStatus != null ||
                _expenseCategoriesStatus != null ||
                _incomeCategoriesStatus != null) ...[
              Text(
                'Export Results',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _StatusCard(
                label: 'currencies.json',
                icon: Icons.currency_exchange_rounded,
                status: _currenciesStatus,
                isSuccess: _currenciesSuccess,
              ),
              const SizedBox(height: 8),
              _StatusCard(
                label: 'accounts.json',
                icon: Icons.account_balance_wallet_rounded,
                status: _accountsStatus,
                isSuccess: _accountsSuccess,
              ),
              const SizedBox(height: 8),
              _StatusCard(
                label: 'transactions.json',
                icon: Icons.receipt_long_rounded,
                status: _transactionsStatus,
                isSuccess: _transactionsSuccess,
              ),
              const SizedBox(height: 8),
              _StatusCard(
                label: 'expenseCategories.json',
                icon: Icons.trending_down,
                status: _expenseCategoriesStatus,
                isSuccess: _expenseCategoriesSuccess,
              ),
              const SizedBox(height: 8),
              _StatusCard(
                label: 'incomeCategories.json',
                icon: Icons.trending_up,
                status: _incomeCategoriesStatus,
                isSuccess: _incomeCategoriesSuccess,
              ),
              const SizedBox(height: 24),
            ],

            // Action button
            FilledButton.icon(
              onPressed: _isLoading ? null : _createBackup,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(_isLoading ? 'Creating backup...' : 'Create Backup'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? status;
  final bool isSuccess;

  const _StatusCard({
    required this.label,
    required this.icon,
    required this.status,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (status == null) return const SizedBox.shrink();

    final color = isSuccess 
      ? const Color(0xFF2E7D32) 
      : colorScheme.error;

    final bgColor = isSuccess 
      ? const Color(0xFFE8F5E9)
      : colorScheme.errorContainer;

    final statusIcon = isSuccess 
      ? Icons.check_circle_rounded 
      : Icons.error_rounded;

    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    status!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(statusIcon, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
