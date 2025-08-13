import 'package:multi_currency_finance/model/common/result/result.dart';

abstract interface class IService<I, O> {
  Future<Result<O>> execute(I params);
}