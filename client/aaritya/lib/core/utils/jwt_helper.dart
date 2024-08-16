import 'package:jwt_decoder/jwt_decoder.dart';

class JwtHelper {
  static bool isExpired(String token) {
    return JwtDecoder.isExpired(token);
  }
}
