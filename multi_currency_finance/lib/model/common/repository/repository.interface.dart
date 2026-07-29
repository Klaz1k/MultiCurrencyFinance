import 'package:multi_currency_finance/model/common/result/result.dart';

abstract interface class IRepository<T> {
  Future<Result<List<T>>> findAll(int? page, int? perPage);
  Future<Result<T>> findById(String id);
  Future<Result<String>> save(T entity);
  Future<Result<String>> delete(String id);
  Future<Result<int>> clear();
}