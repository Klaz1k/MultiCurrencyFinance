import 'package:multi_currency_finance/model/account/entities/balance_amount.dart';

class Balance {
  List<BalanceAmount> balanceQueue;

  Balance({required this.balanceQueue});

  double getCurrentBalance() {
    double currentBalance = 0;
    for (BalanceAmount subBalance in this.balanceQueue) {
      currentBalance += subBalance.amount;
    }
    return currentBalance;
  }

  double add(BalanceAmount amount) {
    this.balanceQueue.add(amount);

    return amount.amount;
  }
  
  List<BalanceAmount> reduce(double amount) {
    List<BalanceAmount> returnList = [];
    double remainder = amount;

    for (BalanceAmount subBalance in this.balanceQueue) {
      var reduceResponse = subBalance.reduce(remainder);

      returnList.add(reduceResponse.balanceSpent);
      if (reduceResponse.remainder <= 0) {
        break;
      }
      this.balanceQueue.remove(subBalance);
    }

    return returnList;
  }
}