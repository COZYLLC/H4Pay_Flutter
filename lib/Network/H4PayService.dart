import 'package:h4pay/Network/InterceptorsWrapper.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/model/Event.dart';
import 'package:h4pay/model/Notice.dart';
import 'package:h4pay/model/Product.dart';
import 'package:h4pay/model/Purchase/Gift.dart';
import 'package:h4pay/model/Purchase/Order.dart';
import 'package:h4pay/model/School.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/model/UserValidResponse.dart';
import 'package:h4pay/model/Voucher.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'H4PayService.g.dart';

H4PayService getService() {
  final Dio dio = new Dio();
  dio.interceptors.add(H4PayInterceptor());

  final H4PayService service = H4PayService(dio, baseUrl: apiUrl!);
  return service;
}

@RestApi(baseUrl: "http://192.168.1.146:3000/api/")
abstract class H4PayService {
  factory H4PayService(Dio dio, {String baseUrl}) = _H4PayService;

  @GET("notices")
  Future<List<Notice>> getNotices();

  @GET("stores")
  Future<bool> getStoreStatus();

  @GET("products/filter?withStored=1")
  Future<List<Product>> getProducts();

  @GET("products/filter?withStored=0")
  Future<List<Product>> getVisibleProducts();

  @GET("schools/filter")
  Future<List<School>> getSchools({
    @Query("id") String? id,
    @Query("name") String? name,
  });

  @POST("users/authpin")
  Future<String> authTel(@Body() Map<String, dynamic> body);

  @POST("users/login") // may not be used
  Future<HttpResponse> login(@Body() Map<String, dynamic> body);

  @POST("users/tokencheck")
  Future<H4PayUser> tokenCheck(
    @Header("X-Access-Token") String token,
  );

  @POST("users/register")
  Future<HttpResponse> register(@Body() Map<String, dynamic> body);

  @POST("users/valid")
  Future<bool> checkUidValid(@Body() Map<String, dynamic> body);

  @POST("users/changepass")
  Future<HttpResponse> changePassword(@Body() Map<String, dynamic> body);

  @POST("users/withdrawl")
  Future<HttpResponse> withdraw(@Body() Map<String, dynamic> body);

  @POST("users/find/uid")
  Future<HttpResponse> findUid(@Body() Map<String, dynamic> body);

  @POST("users/find/password")
  Future<HttpResponse> findPassword(@Body() Map<String, dynamic> body);

  @GET("orders/filter")
  Future<List<Order>> getOrders(@Path("uid") String uid);

  @POST("orders/create")
  Future<HttpResponse> createOrder(@Body() Map<String, dynamic> body);

  @GET("orders/cancel/{orderId}")
  Future<HttpResponse> cancelOrder(@Path("orderId") String orderId);

  @POST("gifts/create")
  Future<HttpResponse> createGift(@Body() Map<String, dynamic> body);

  @POST("gifts/create/kakao")
  Future<HttpResponse> createKakaoGift(@Body() Map<String, dynamic> body);

  @GET("gifts/filter")
  Future<List<Gift>> getGifts(@Query("uidTo") String uidTo);

  @GET("gifts/filter")
  Future<List<Gift>> getGiftDetail(@Query("orderId") String orderId);

  @GET("gifts/filter")
  Future<List<Gift>> getSentGifts(@Query("uidFrom") String uidFrom);

  @POST("gifts/{orderId}/extend")
  Future<HttpResponse> extendGift(@Path("orderId") String orderId);

  @GET("vouchers/filter")
  Future<List<Voucher>> getVouchers(@Query("tel") String tel);

  @GET("vouchers/filter")
  Future<List<Voucher>> getVoucherDetail(@Query("id") String id);

  @GET("events")
  Future<List<Event>> getAllEvents();

  @GET("events/{uid}/match")
  Future<List<Event>> getMatchingEvents(@Path("uid") String uid);
}

@JsonSerializable()
class ResponseWrapper {
  bool status;
  dynamic result;
  String? message;
  ResponseWrapper({required this.status, this.result, this.message});

  factory ResponseWrapper.fromJson(Map<String, dynamic> json) =>
      _$ResponseWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseWrapperToJson(this);
}
