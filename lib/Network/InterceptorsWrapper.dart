import 'package:dio/dio.dart';
import 'package:h4pay/Network/H4PayService.dart';

class H4PayInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final Map<String, dynamic> rawJsonResponse = response.data ?? "{}";
    final ResponseWrapper responseWrapper =
        ResponseWrapper.fromJson(rawJsonResponse);
    response.statusMessage = responseWrapper.message ?? response.statusMessage;
    response.data = responseWrapper.result;
    print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    return super.onError(err, handler);
  }
}
