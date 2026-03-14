/* Generated - run "serverpod generate" to update. */
import 'package:serverpod/serverpod.dart' as _i1;

abstract class ProfileResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ProfileResponse._({
    this.displayName,
    this.email,
    this.phone,
    this.birthDate,
  });

  factory ProfileResponse({
    String? displayName,
    String? email,
    String? phone,
    String? birthDate,
  }) = _ProfileResponseImpl;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      birthDate: json['birthDate'] as String?,
    );
  }

  String? displayName;
  String? email;
  String? phone;
  String? birthDate;

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileResponse',
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() => toJson();

  @override
  String toString() => _i1.SerializationManager.encode(this);
}

class _ProfileResponseImpl extends ProfileResponse {
  _ProfileResponseImpl({
    String? displayName,
    String? email,
    String? phone,
    String? birthDate,
  }) : super._(
          displayName: displayName,
          email: email,
          phone: phone,
          birthDate: birthDate,
        );
}
