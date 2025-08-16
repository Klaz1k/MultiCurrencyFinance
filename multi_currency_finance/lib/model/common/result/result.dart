import 'package:multi_currency_finance/model/common/errors/incorrect_result_usage.dart';

class Result<T> {
  late final T? _value;
  late final Error? _error;
  late final bool _isError;

  factory Result.success(T value) {
    return Result._internal(value: value, isError: false);
  }

  factory Result.failure(Error error) {
    return Result._internal(error: error, isError: true);
  }

  Result._internal({T? value, Error? error, required bool isError}) {
    this._value = value;
    this._error = error;
    this._isError = isError;
  }

  bool get isError => this._isError;

  T get value {
    if (this._isError) throw IncorrectResultUsageError();

    return this._value!;
  }

  Error get error {
    if (!this._isError) throw IncorrectResultUsageError();

    return this._error!;
  }
}