import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';

class Balance {
  late final List<BalanceAmount> _balanceQueue;

  List<BalanceAmount> get balanceQueue {
    List<BalanceAmount> list = [];
    for (BalanceAmount entry in this._balanceQueue) {
      list.add(BalanceAmount(amount: entry.amount, exchangeRate: entry.exchangeRate));
    }
    return list;
  }

  Balance({required List<BalanceAmount> balanceQueue}) :
    this._balanceQueue = balanceQueue;

  double getCurrentBalance() {
    double currentBalance = 0;
    for (BalanceAmount subBalance in this._balanceQueue) {
      currentBalance += subBalance.amount;
    }
    return currentBalance;
  }

double exchangedBalance() {
  double exchangedBalance = 0;
  for (BalanceAmount subBalance in this._balanceQueue) {
    exchangedBalance += (subBalance.amount/subBalance.exchangeRate);
  }
  return exchangedBalance;
}

  BalanceAmount add(BalanceAmount amount) {
    this._balanceQueue.add(amount);

    return amount;
  }
  
  List<BalanceAmount> reduce(double amount) {
    List<BalanceAmount> returnList = [];
    double remainder = amount;

    for (BalanceAmount subBalance in this._balanceQueue) {
      var reduceResponse = subBalance.reduce(remainder);

      returnList.add(reduceResponse.balanceSpent);
      if (reduceResponse.remainder <= 0) {
        break;
      }
      this._balanceQueue.remove(subBalance);
    }

    return returnList;
  }
}