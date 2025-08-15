class BalanceAmount {
  late double _amount;
  late final double exchangeRate;

  double get amount => this._amount;

  BalanceAmount(this._amount, this.exchangeRate);

({double remainder, BalanceAmount balanceSpent}) reduce(double amount) {
    late ({double remainder, BalanceAmount balanceSpent}) result;

    if (amount >= this._amount) {
      result = (remainder: amount - this._amount, balanceSpent: BalanceAmount(this._amount, this.exchangeRate));
    } else {
      result = (remainder: 0, balanceSpent: BalanceAmount(this._amount - amount, this.exchangeRate));
      this._amount -= amount;
    }

    return result;
  }
}