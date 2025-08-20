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
      this._amount = 0;
    } else {
      amountSpent = amount;
      this._amount -= amount;
    }

    return (remainder: amount - amountSpent, balanceSpent: BalanceAmount(amount: amountSpent, exchangeRate: this.exchangeRate));
  }
}