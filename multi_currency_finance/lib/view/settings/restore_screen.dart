import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/account/mappers/json/account_json.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
import 'package:multi_currency_finance/controller/backup/services/clear_all_data_service.dart';
import 'package:multi_currency_finance/controller/backup/services/get_backup_data_service.dart';
import 'package:multi_currency_finance/controller/backup/services/load_data_from_backup_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/mappers/json/currency_json.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_repository.dart';
import 'package:multi_currency_finance/controller/transaction/mappers/json/transaction_json.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_repository.dart';
import 'package:path_provider/path_provider.dart';

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key});

  @override
  RestoreScreenState createState() => RestoreScreenState();
}

class RestoreScreenState extends State<RestoreScreen> {
  // ── Services ───────────────────────────────────────────────────────────────
  final IService<GetBackupDataRequest, GetBackupDataResponse>
      _getBackupDataService = GetBackupDataService(
    currencyRepository: HiveCurrencyRepository.instance,
    accountRepository: HiveAccountRepository.instance,
    transactionRepository: HiveTransactionRepository.instance,
  );

  final IService<ClearAllDataServiceRequest, ClearAllDataServiceResponse>
      _clearAllDataService = ClearAllDataService(
    currencyRepository: HiveCurrencyRepository.instance,
    accountRepository: HiveAccountRepository.instance,
    transactionRepository: HiveTransactionRepository.instance,
  );

  final IService<LoadDataFromBackupRequest, LoadDataFromBackupResponse>
      _loadDataFromBackupService = LoadDataFromBackupService(
    currencyRepository: HiveCurrencyRepository.instance,
    accountRepository: HiveAccountRepository.instance,
    transactionRepository: HiveTransactionRepository.instance,
  );

  // ── Pre-restore backup state ───────────────────────────────────────────────
  bool _wantsPreBackup = false;
  String? _backupDirectory;
  // bool _backupInProgress = false;

  String? _backupCurrenciesStatus;
  String? _backupAccountsStatus;
  String? _backupTransactionsStatus;
  bool _backupCurrenciesSuccess = false;
  bool _backupAccountsSuccess = false;
  bool _backupTransactionsSuccess = false;

  // ── File-selection state ───────────────────────────────────────────────────
  String? _currenciesFilePath;
  String? _accountsFilePath;
  String? _transactionsFilePath;

  List<CurrencyJson>? _currencies;
  List<AccountJson>? _accounts;
  List<TransactionJson>? _transactions;

  String? _currenciesParseError;
  String? _accountsParseError;
  String? _transactionsParseError;

  // ── Restore state ─────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _restoreSuccessMessage;
  String? _restoreErrorMessage;

  // ── Computed helpers ───────────────────────────────────────────────────────

  bool get _allFilesReady =>
      _currencies != null &&
      _accounts != null &&
      _transactions != null &&
      _currenciesParseError == null &&
      _accountsParseError == null &&
      _transactionsParseError == null;

  bool get _canRestore =>
      _allFilesReady &&
      !_isLoading &&
      (!_wantsPreBackup || _backupDirectory != null);

  /// Reads a file and parses its content as a JSON array.
  Future<List<Map<String, dynamic>>> _readJsonArray(String path) async {
    final content = await File(path).readAsString();
    final decoded = jsonDecode(content);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array at the root level.');
    }
    return decoded.cast<Map<String, dynamic>>();
  }

  // ── File pickers ──────────────────────────────────────────────────────────

  Future<void> _pickCurrenciesFile() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Select currencies.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      lockParentWindow: true,
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    setState(() {
      _currenciesFilePath = path;
      _currencies = null;
      _currenciesParseError = null;
    });
    try {
      final rows = await _readJsonArray(path);
      final parsed = rows.map((e) => CurrencyJson.fromJson(e)).toList();
      setState(() => _currencies = parsed);
    } catch (e) {
      setState(() => _currenciesParseError = 'Error while parsing, please be sure to choose a correctly formatted json file');
    }
  }

  Future<void> _pickAccountsFile() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Select accounts.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      lockParentWindow: true,
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    setState(() {
      _accountsFilePath = path;
      _accounts = null;
      _accountsParseError = null;
    });
    try {
      final rows = await _readJsonArray(path);
      final parsed = rows.map((e) => AccountJson.fromJson(e)).toList();
      setState(() => _accounts = parsed);
    } catch (e) {
      setState(() => _accountsParseError = 'Error while parsing, please be sure to choose a correctly formatted json file');
    }
  }

  Future<void> _pickTransactionsFile() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Select transactions.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      lockParentWindow: true,
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    setState(() {
      _transactionsFilePath = path;
      _transactions = null;
      _transactionsParseError = null;
    });
    try {
      final rows = await _readJsonArray(path);
      final parsed = rows.map((e) => TransactionJson.fromJson(e)).toList();
      setState(() => _transactions = parsed);
    } catch (e) {
      setState(() => _transactionsParseError = 'Error while parsing, please be sure to choose a correctly formatted json file');
    }
  }

  Future<void> _pickBackupDirectory() async {
    // final path = await FilePicker.getDirectoryPath(
    //   dialogTitle: 'Pick location for pre-restore backup',
    //   lockParentWindow: true,
    // );
    final directory = await getDownloadsDirectory();
    
    if (directory == null) return;

    final path = "${directory.path}/MultiCurrencyBackups";

    setState(() {
      _backupDirectory = path;
      _backupCurrenciesStatus = "Will be saved to: $_backupDirectory";
      _backupCurrenciesSuccess = true;
      _backupAccountsStatus = "Will be saved to: $_backupDirectory";
      _backupAccountsSuccess = true;
      _backupTransactionsStatus = "Will be saved to: $_backupDirectory";
      _backupTransactionsSuccess = true;
    });
  }

  // ── Pre-restore backup ────────────────────────────────────────────────────

  Future<bool> _runPreRestoreBackup() async {
    setState(() {
      // _backupInProgress = true;
      _backupCurrenciesStatus = null;
      _backupAccountsStatus = null;
      _backupTransactionsStatus = null;
      _backupCurrenciesSuccess = false;
      _backupAccountsSuccess = false;
      _backupTransactionsSuccess = false;
    });

    final result = await _getBackupDataService.execute(GetBackupDataRequest());

    if (result.isError) {
      setState(() {
        // _backupInProgress = false;
        _backupCurrenciesStatus = 'Failed to load data from database.';
        _backupAccountsStatus = 'Failed to load data from database.';
        _backupTransactionsStatus = 'Failed to load data from database.';
      });
      return false;
    }

    final data = result.value;
    final path = _backupDirectory!;

    final currenciesJson = const JsonEncoder.withIndent('  ')
        .convert(data.currencies.map((c) => c.toJson()).toList());
    final accountsJson = const JsonEncoder.withIndent('  ')
        .convert(data.accounts.map((a) => a.toJson()).toList());
    final transactionsJson = const JsonEncoder.withIndent('  ')
        .convert(data.transactions.map((t) => t.toJson()).toList());

    bool allOk = true;

    try {
      await _saveJsonFile(
        fileName: 'currencies_preRestore.json',
        path: path,
        content: currenciesJson,
        onSuccess: (file) => setState(() {
          _backupCurrenciesStatus = 'Saved to ${file.path}';
          _backupCurrenciesSuccess = true;
        }),
      );
    } catch (e) {
      setState(() => _backupCurrenciesStatus = 'Error: $e');
      allOk = false;
    }

    try {
      await _saveJsonFile(
        fileName: 'accounts_preRestore.json',
        path: path,
        content: accountsJson,
        onSuccess: (file) => setState(() {
          _backupAccountsStatus = 'Saved to ${file.path}';
          _backupAccountsSuccess = true;
        }),
      );
    } catch (e) {
      setState(() => _backupAccountsStatus = 'Error: $e');
      allOk = false;
    }

    try {
      await _saveJsonFile(
        fileName: 'transactions_preRestore.json',
        path: path,
        content: transactionsJson,
        onSuccess: (file) => setState(() {
          _backupTransactionsStatus = 'Saved to ${file.path}';
          _backupTransactionsSuccess = true;
        }),
      );
    } catch (e) {
      setState(() => _backupTransactionsStatus = 'Error: $e');
      allOk = false;
    }

    // setState(() => _backupInProgress = false);
    return allOk;
  }

  Future<void> _saveJsonFile({
    required String fileName,
    required String path,
    required String content,
    required void Function(File file) onSuccess,
  }) async {
    final file = File('$path/$fileName');
    final written = await file.writeAsString(content);
    onSuccess(written);
  }

  // ── Restore flow ──────────────────────────────────────────────────────────

  Future<void> _confirmAndRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 40,
          ),
          title: const Text('Confirm Restore'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action will permanently erase all current data '
                'before importing from the selected files.',
                style: theme.textTheme.bodyMedium,
              ),
              if (_wantsPreBackup && _backupDirectory != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A backup will be saved to "$_backupDirectory" first.',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Files to import:',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              _ConfirmRow(
                icon: Icons.currency_exchange_rounded,
                label:
                    '${_currencies!.length} currenc${_currencies!.length == 1 ? 'y' : 'ies'}',
              ),
              _ConfirmRow(
                icon: Icons.account_balance_wallet_rounded,
                label:
                    '${_accounts!.length} account${_accounts!.length == 1 ? '' : 's'}',
              ),
              _ConfirmRow(
                icon: Icons.receipt_long_rounded,
                label:
                    '${_transactions!.length} transaction${_transactions!.length == 1 ? '' : 's'}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
              ),
              child: const Text('Erase & Restore'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _restoreSuccessMessage = null;
      _restoreErrorMessage = null;
    });

    // 1. Optional pre-restore backup
    if (_wantsPreBackup && _backupDirectory != null) {
      final backupOk = await _runPreRestoreBackup();
      if (!backupOk) {
        setState(() {
          _isLoading = false;
          _restoreErrorMessage = 'Pre-restore backup failed. Restore aborted to protect your data.';
        });
        return;
      }
    }

    // 2. Clear database
    final clearResult = await _clearAllDataService.execute(ClearAllDataServiceRequest());
    if (clearResult.isError) {
      setState(() {
        _isLoading = false;
        _restoreErrorMessage = 'Failed to clear database: ${clearResult.error}';
      });
      return;
    }

    // 3. Load from files
    final loadResult = await _loadDataFromBackupService.execute(
      LoadDataFromBackupRequest(
        currencies: _currencies!,
        accounts: _accounts!,
        transactions: _transactions!,
      ),
    );

    setState(() {
      _isLoading = false;
      if (loadResult.isError) {
        _restoreErrorMessage = 'Restore failed: ${loadResult.error}';
      } else {
        _restoreSuccessMessage = 'Restore completed successfully!\n'
            '• ${_currencies!.length} currencies\n'
            '• ${_accounts!.length} accounts\n'
            '• ${_transactions!.length} transactions';
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore From Backup'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header card ────────────────────────────────────────────────
            Card(
              elevation: 0,
              color: colorScheme.secondaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.restore_rounded,
                      size: 48,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Restore From Backup',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select one JSON file per entity. The current database '
                      'will be cleared before importing.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Pre-restore backup section ─────────────────────────────────
            _SectionHeader(
              icon: Icons.backup_rounded,
              title: 'Pre-Restore Backup',
              color: colorScheme.primary,
              theme: theme,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Back up current data first'),
                    subtitle: const Text('Save a copy of the database before erasing it'),
                    value: _wantsPreBackup,
                    onChanged: _isLoading
                        ? null
                        : (v) => setState(() {
                              _wantsPreBackup = v;
                              if (!v) {
                                _backupDirectory = null;
                                _backupCurrenciesStatus = null;
                                _backupAccountsStatus = null;
                                _backupTransactionsStatus = null;
                              } else {
                                _pickBackupDirectory();
                              }
                            }),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  if (_wantsPreBackup) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Icon(Icons.folder_open_rounded, color: colorScheme.secondary),
                      title: Text(
                        _backupDirectory ?? 'No folder selected',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _backupDirectory != null
                              ? null
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // subtitle: const Text('Backup destination folder'),
                      // trailing: TextButton(
                      //   onPressed: _isLoading ? null : _pickBackupDirectory,
                      //   child: Text(_backupDirectory == null ? 'Choose' : 'Change'),
                      // ),
                      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    // Backup status cards (shown after the backup runs)
                    if (_backupCurrenciesStatus != null ||
                        _backupAccountsStatus != null ||
                        _backupTransactionsStatus != null) ...[
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          children: [
                            _StatusCard(
                              label: 'currencies.json',
                              icon: Icons.currency_exchange_rounded,
                              status: _backupCurrenciesStatus,
                              isSuccess: _backupCurrenciesSuccess,
                            ),
                            const SizedBox(height: 6),
                            _StatusCard(
                              label: 'accounts.json',
                              icon: Icons.account_balance_wallet_rounded,
                              status: _backupAccountsStatus,
                              isSuccess: _backupAccountsSuccess,
                            ),
                            const SizedBox(height: 6),
                            _StatusCard(
                              label: 'transactions.json',
                              icon: Icons.receipt_long_rounded,
                              status: _backupTransactionsStatus,
                              isSuccess: _backupTransactionsSuccess,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── File selection section ─────────────────────────────────────
            _SectionHeader(
              icon: Icons.file_open_rounded,
              title: 'Select Files to Restore',
              color: colorScheme.primary,
              theme: theme,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _FilePickerRow(
                    icon: Icons.currency_exchange_rounded,
                    label: 'Currencies',
                    hint: 'currencies.json',
                    filePath: _currenciesFilePath,
                    parsedCount: _currencies?.length,
                    parseError: _currenciesParseError,
                    isLoading: _isLoading,
                    onPick: _pickCurrenciesFile,
                    isFirst: true,
                    isLast: false,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _FilePickerRow(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Accounts',
                    hint: 'accounts.json',
                    filePath: _accountsFilePath,
                    parsedCount: _accounts?.length,
                    parseError: _accountsParseError,
                    isLoading: _isLoading,
                    onPick: _pickAccountsFile,
                    isFirst: false,
                    isLast: false,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _FilePickerRow(
                    icon: Icons.receipt_long_rounded,
                    label: 'Transactions',
                    hint: 'transactions.json',
                    filePath: _transactionsFilePath,
                    parsedCount: _transactions?.length,
                    parseError: _transactionsParseError,
                    isLoading: _isLoading,
                    onPick: _pickTransactionsFile,
                    isFirst: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Result banners ─────────────────────────────────────────────
            if (_restoreSuccessMessage != null) ...[
              _ResultBanner(
                message: _restoreSuccessMessage!,
                isSuccess: true,
              ),
              const SizedBox(height: 16),
            ],
            if (_restoreErrorMessage != null) ...[
              _ResultBanner(
                message: _restoreErrorMessage!,
                isSuccess: false,
              ),
              const SizedBox(height: 16),
            ],

            // ── Restore button ─────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _canRestore ? _confirmAndRestore : null,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.restore_rounded),
              label: Text(_isLoading ? 'Restoring...' : 'Restore'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            if (!_allFilesReady ||
                (_wantsPreBackup && _backupDirectory == null))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _buildHintText(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _buildHintText() {
    if (_currenciesParseError != null ||
        _accountsParseError != null ||
        _transactionsParseError != null) {
      return 'Fix the file errors above to enable restore.';
    }
    final missing = <String>[];
    if (_currencies == null) missing.add('currencies');
    if (_accounts == null) missing.add('accounts');
    if (_transactions == null) missing.add('transactions');
    if (missing.isNotEmpty) {
      return 'Select a file for: ${missing.join(', ')}.';
    }
    if (_wantsPreBackup && _backupDirectory == null) {
      return 'Choose a backup destination folder to continue.';
    }
    return '';
  }
}

// ── Private helper widgets ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final ThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FilePickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final String? filePath;
  final int? parsedCount;
  final String? parseError;
  final bool isLoading;
  final VoidCallback onPick;
  final bool isFirst;
  final bool isLast;

  const _FilePickerRow({
    required this.icon,
    required this.label,
    required this.hint,
    required this.filePath,
    required this.parsedCount,
    required this.parseError,
    required this.isLoading,
    required this.onPick,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasError = parseError != null;
    final hasSuccess = parsedCount != null && !hasError;

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? 12 : 0),
      topRight: Radius.circular(isFirst ? 12 : 0),
      bottomLeft: Radius.circular(isLast ? 12 : 0),
      bottomRight: Radius.circular(isLast ? 12 : 0),
    );

    return InkWell(
      onTap: isLoading ? null : onPick,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasError
                  ? colorScheme.error
                  : hasSuccess
                      ? const Color(0xFF2E7D32)
                      : colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  if (filePath == null)
                    Text(
                      'Tap to select $hint',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    )
                  else if (hasError) ...[
                    Text(
                      filePath!.split(Platform.pathSeparator).last,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      parseError!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.error),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    Text(
                      filePath!.split(Platform.pathSeparator).last,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (parsedCount != null)
                      Text(
                        '$parsedCount record${parsedCount == 1 ? '' : 's'} parsed',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: const Color(0xFF2E7D32)),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (hasError)
              Icon(Icons.error_rounded, color: colorScheme.error, size: 20)
            else if (hasSuccess)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32), size: 20)
            else
              Icon(Icons.upload_file_rounded,
                  color: colorScheme.onSurfaceVariant, size: 20),
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
    if (status == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final color = isSuccess ? const Color(0xFF2E7D32) : colorScheme.error;
    final bgColor =
        isSuccess ? const Color(0xFFE8F5E9) : colorScheme.errorContainer;
    final statusIcon =
        isSuccess ? Icons.check_circle_rounded : Icons.error_rounded;

    return Card(
      elevation: 0,
      color: bgColor,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    status!,
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(statusIcon, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const _ResultBanner({required this.message, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final color = isSuccess ? const Color(0xFF2E7D32) : colorScheme.error;
    final bgColor =
        isSuccess ? const Color(0xFFE8F5E9) : colorScheme.errorContainer;
    final icon =
        isSuccess ? Icons.check_circle_rounded : Icons.error_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ConfirmRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
