/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
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

  factory ProfileResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProfileResponse(
      displayName: jsonSerialization['displayName'] as String?,
      email: jsonSerialization['email'] as String?,
      phone: jsonSerialization['phone'] as String?,
      birthDate: jsonSerialization['birthDate'] as String?,
    );
  }

  String? displayName;

  String? email;

  String? phone;

  String? birthDate;

  /// Returns a shallow copy of this [ProfileResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProfileResponse copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? birthDate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileResponse',
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (birthDate != null) 'birthDate': birthDate,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProfileResponse',
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (birthDate != null) 'birthDate': birthDate,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

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

  /// Returns a shallow copy of this [ProfileResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProfileResponse copyWith({
    Object? displayName = _Undefined,
    Object? email = _Undefined,
    Object? phone = _Undefined,
    Object? birthDate = _Undefined,
  }) {
    return ProfileResponse(
      displayName: displayName is String? ? displayName : this.displayName,
      email: email is String? ? email : this.email,
      phone: phone is String? ? phone : this.phone,
      birthDate: birthDate is String? ? birthDate : this.birthDate,
    );
  }
}
