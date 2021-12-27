import 'package:h4pay/Purchase/Purchase.dart';

class H4PayResult {
  final bool success;
  final dynamic data;

  H4PayResult({
    required this.success,
    required this.data,
  });

  H4PayResult.purchase({
    required this.success,
    required Purchase? this.data,
  });
  H4PayResult.network({
    required this.success,
    required String this.data,
  });
}
