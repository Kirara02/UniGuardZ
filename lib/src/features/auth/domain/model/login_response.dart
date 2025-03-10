import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ugz_app/src/features/auth/domain/model/user.dart';

part 'login_response.g.dart';
part 'login_response.freezed.dart';

@freezed
abstract class LoginResponse with _$LoginResponse {
  factory LoginResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    required User user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
