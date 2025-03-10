import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  factory User({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'mobile_access') bool? mobileAccess,
    @JsonKey(name: 'web_access') bool? webAccess,
    @JsonKey(name: 'system_access') bool? systemAccess,
    @JsonKey(name: 'parent_branch') required ParentBranch parentBranch,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class ParentBranch with _$ParentBranch {
  const factory ParentBranch({
    required String id,
    @JsonKey(name: 'gps_tracking_enabled') required bool gpsTrackingEnabled,
    @JsonKey(name: 'gps_interval') required int gpsInterval,
  }) = _ParentBranch;

  factory ParentBranch.fromJson(Map<String, dynamic> json) =>
      _$ParentBranchFromJson(json);
}
