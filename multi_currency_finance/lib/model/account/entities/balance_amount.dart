class BalanceAmount {
  late double _amount;
  late final double _exchangeRate;

  double get amount => this._amount;
  double get exchangeRate => this._exchangeRate;

  BalanceAmount({required double amount, required double exchangeRate}) : _exchangeRate = exchangeRate, _amount = amount;

({double remainder, BalanceAmount balanceSpent}) reduce(double amount) {
    late ({double remainder, BalanceAmount balanceSpent}) result;

    if (amount >= this._amount) {
      result = (remainder: amount - this._amount, balanceSpent: BalanceAmount(amount: this._amount, exchangeRate: this._exchangeRate));
    } else {
      result = (remainder: 0, balanceSpent: BalanceAmount(amount: this._amount - amount, exchangeRate: this._exchangeRate));
      this._amount -= amount;
    }

    return result;
  }
}