class BalanceAmount {
  late double _amount;
  late final double exchangeRate;

  double get amount => this._amount;

  BalanceAmount({required double amount, required this.exchangeRate}) : 
    this._amount = amount;

({double remainder, BalanceAmount balanceSpent}) reduce(double amount) {
    late double amountSpent;

    if (amount >= this._amount) {
      amountSpent = this._amount;
    } else {
      amountSpent = this._amount - amount;
      this._amount -= amount;
    }

    return (remainder: amount - this._amount, balanceSpent: BalanceAmount(amount: amountSpent, exchangeRate: this.exchangeRate));
  }
}