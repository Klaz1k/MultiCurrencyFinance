import 'package:multi_currency_finance/model/common/errors/incorrect_result_usage.dart';

class Result<T> {
  late final T? _value;
  late final Error? _error;
  late final bool _isError;

  Result._(T? value, Error? error, bool isError) {
    this._value = value;
    this._error = error;
    this._isError = isError;
  }

  T get value {
    if (this._isError) throw IncorrectResultUsageError();

    return this._value!;
  }

  Error get error {
    if (!this._isError) throw IncorrectResultUsageError();

    return this._error!;
  }
}