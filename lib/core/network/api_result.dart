import 'package:osta/core/network/pagination_meta.dart';

/// Parsed success envelope: typed [data] plus optional pagination [meta].
class ApiResult<T> {
  const ApiResult(this.data, {this.meta});

  final T data;
  final PaginationMeta? meta;
}
