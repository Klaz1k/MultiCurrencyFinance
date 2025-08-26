import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/common/uuid/uuid_generator.dart';
import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/common/result/result.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/repository/transaction_repository.interface.dart';
import 'package:multi_currency_finance/model/transaction/structures/transaction_type.dart';
import 'package:multi_currency_finance/model/transaction/transaction.dart';

class MakeTransferService implements IService<MakeTransferRequest, MakeTransferResponse> {
  late final ITransactionRepository _transactionRepository;
  late final IAccountRepository _accountRepository;
  late final ICurrencyRepository _currencyRepository;

  MakeTransferService({required ITransactionRepository transactionRespository, required IAccountRepository accountRepository, required ICurrencyRepository currencyRepository}) :
    this._accountRepository = accountRepository,
    this._transactionRepository = transactionRespository,
    this._currencyRepository = currencyRepository;

  @override
  Future<Result<MakeTransferResponse>> execute(MakeTransferRequest params) async {
    final transferingAccountResult = await this._accountRepository.findById(params.transferingAccountId);

    if (transferingAccountResult.isError) return Result.failure(transferingAccountResult.error);

    final receivingAccountResult = await this._accountRepository.findById(params.receivingAccountId);

    if (receivingAccountResult.isError) return Result.failure(receivingAccountResult.error);

    final outgoingBalance = transferingAccountResult.value.withdraw(params.outgoingAmount);

    final incomingCurrencyResult = await this._currencyRepository.findById(receivingAccountResult.value.currencyId);

    if (incomingCurrencyResult.isError) return Result.failure(incomingCurrencyResult.error);
    
    late final double exchangeRate;
    if (incomingCurrencyResult.value.isMain) {
      exchangeRate = 1.0;
    } else {
      final outgoingCurrencyResult = await this._currencyRepository.findById(transferingAccountResult.value.currencyId);

      if (outgoingCurrencyResult.isError) return Result.failure(outgoingCurrencyResult.error);

      if (outgoingCurrencyResult.value.isMain) {
        exchangeRate = (params.incomingAmount / params.outgoingAmount);
      } else {
        double convertedOutgoingBalance = 0;
        for (final subBalance in outgoingBalance) {
          convertedOutgoingBalance += subBalance.amount / subBalance.exchangeRate;
        }
        exchangeRate = (params.incomingAmount / convertedOutgoingBalance);
      }
    }

    final incomingBalance = receivingAccountResult.value.deposit(
        BalanceAmount(
          amount: params.incomingAmount, 
          exchangeRate: exchangeRate
        )
      );
    final uuidGenerator = UuidGenerator.instance;

    final outgoingTransferSaveResult = await this._transactionRepository.save(
      Transaction(
        id: uuidGenerator.v4(), 
        transactionType: TransactionType.OutgoingTransfer, 
        date: DateTime.now(), 
        currencyId: transferingAccountResult.value.currencyId, 
        transactedAmount: outgoingBalance, 
        relatedAccountId: transferingAccountResult.value.id
      )
    );

    if (outgoingTransferSaveResult.isError) return Result.failure(outgoingTransferSaveResult.error);

    final incomingTranferSaveResult = await this._transactionRepository.save(
      Transaction(
        id: uuidGenerator.v4(), 
        transactionType: TransactionType.IncomingTransfer, 
        date: DateTime.now(), 
        currencyId: receivingAccountResult.value.currencyId, 
        transactedAmount: [incomingBalance], 
        relatedAccountId: receivingAccountResult.value.id
      )
    );

    if (incomingTranferSaveResult.isError) return Result.failure(incomingTranferSaveResult.error);

    return Result.success(
      MakeTransferResponse(
        outgoingTransactionId: outgoingTransferSaveResult.value, 
        incomingTransactionId: incomingTranferSaveResult.value
      )
    );
  }
}

class MakeTransferRequest {
  late final String transferingAccountId;
  late final String receivingAccountId;
  late final double outgoingAmount;
  late final double incomingAmount;

  MakeTransferRequest({required this.transferingAccountId, required this.receivingAccountId, required this.outgoingAmount, required this.incomingAmount});
}

class MakeTransferResponse {
  late final String outgoingTransactionId;
  late final String incomingTransactionId;

  MakeTransferResponse({required outgoingTransactionId, required incomingTransactionId});
}