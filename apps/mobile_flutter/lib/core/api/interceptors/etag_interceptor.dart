import 'package:dio/dio.dart';
import '../../../data/local/daos/etag_dao.dart';

class EtagInterceptor extends Interceptor {
  final EtagDao etagDao;

  EtagInterceptor(this.etagDao);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.method == 'GET') {
      final etag = await etagDao.getEtag(options.uri.toString());
      if (etag != null) {
        options.headers['If-None-Match'] = etag;
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final etag = response.headers.value('ETag');
    if (etag != null && response.statusCode == 200) {
      await etagDao.updateEtag(response.requestOptions.uri.toString(), etag);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 304) {
      // If 304, we don't treat it as an error for the repository to handle.
      // However, Dio throws by default. We can resolve it with a custom response.
      handler.resolve(Response(
        requestOptions: err.requestOptions,
        statusCode: 304,
        headers: err.response?.headers ?? Headers(),
      ));
    } else {
      handler.next(err);
    }
  }
}
