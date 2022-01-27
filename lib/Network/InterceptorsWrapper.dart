import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/User.dart';

class H4PayInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    final H4PayUser? user = await userFromStorage();
    if (user == null) {
      throw UserNotFoundException();
    } else {
      options.headers['x-access-token'] = user.token;
      return super.onRequest(options, handler);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final Map<String, dynamic> rawJsonResponse =
        response.data.runtimeType == String
            ? json.decode(response.data)
            : response.data ?? {};
    final ResponseWrapper responseWrapper =
        ResponseWrapper.fromJson(rawJsonResponse);
    response.statusMessage = responseWrapper.message ?? response.statusMessage;
    response.data = responseWrapper.result;
    print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print(responseWrapper.result);
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    return super.onError(err, handler);
  }
}
