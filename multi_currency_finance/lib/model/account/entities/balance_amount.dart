class BalanceAmount {
  late double _amount;
  late final double exchangeRate;

  double get amount => this._amount;

  BalanceAmount({required double amount, required this.exchangeRate}) : 
    this._amount = amount;

({double remainder, BalanceAmount balanceSpent}) reduce(double amount) {
    late ({double remainder, BalanceAmount balanceSpent}) result;

    if (amount >= this._amount) {
      result = (remainder: amount - this._amount, balanceSpent: BalanceAmount(amount:  this._amount, exchangeRate: this.exchangeRate));
    } else {
      result = (remainder: 0, balanceSpent: BalanceAmount(amount:  this._amount - amount, exchangeRate: this.exchangeRate));
      this._amount -= amount;
    }

    return result;
  }
}