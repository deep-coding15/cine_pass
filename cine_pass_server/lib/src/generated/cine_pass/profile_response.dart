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
    this.userId,
    this.displayName,
    this.email,
    this.phone,
    this.birthDate,
    this.role,
    this.active,
    this.createdAt,
  });

  factory ProfileResponse({
    String? userId,
    String? displayName,
    String? email,
    String? phone,
    String? birthDate,
    String? role,
    bool? active,
    String? createdAt,
  }) = _ProfileResponseImpl;

  factory ProfileResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProfileResponse(
      userId: jsonSerialization['userId'] as String?,
      displayName: jsonSerialization['displayName'] as String?,
      email: jsonSerialization['email'] as String?,
      phone: jsonSerialization['phone'] as String?,
      birthDate: jsonSerialization['birthDate'] as String?,
      role: jsonSerialization['role'] as String?,
      active: jsonSerialization['active'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['active']),
      createdAt: jsonSerialization['createdAt'] as String?,
    );
  }

  String? userId;

  String? displayName;

  String? email;

  String? phone;

  String? birthDate;

  String? role;

  bool? active;

  String? createdAt;

  /// Returns a shallow copy of this [ProfileResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProfileResponse copyWith({
    String? userId,
    String? displayName,
    String? email,
    String? phone,
    String? birthDate,
    String? role,
    bool? active,
    String? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileResponse',
      if (userId != null) 'userId': userId,
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (birthDate != null) 'birthDate': birthDate,
      if (role != null) 'role': role,
      if (active != null) 'active': active,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProfileResponse',
      if (userId != null) 'userId': userId,
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (birthDate != null) 'birthDate': birthDate,
      if (role != null) 'role': role,
      if (active != null) 'active': active,
      if (createdAt != null) 'createdAt': createdAt,
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
    String? userId,
    String? displayName,
    String? email,
    String? phone,
    String? birthDate,
    String? role,
    bool? active,
    String? createdAt,
  }) : super._(
         userId: userId,
         displayName: displayName,
         email: email,
         phone: phone,
         birthDate: birthDate,
         role: role,
         active: active,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ProfileResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProfileResponse copyWith({
    Object? userId = _Undefined,
    Object? displayName = _Undefined,
    Object? email = _Undefined,
    Object? phone = _Undefined,
    Object? birthDate = _Undefined,
    Object? role = _Undefined,
    Object? active = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return ProfileResponse(
      userId: userId is String? ? userId : this.userId,
      displayName: displayName is String? ? displayName : this.displayName,
      email: email is String? ? email : this.email,
      phone: phone is String? ? phone : this.phone,
      birthDate: birthDate is String? ? birthDate : this.birthDate,
      role: role is String? ? role : this.role,
      active: active is bool? ? active : this.active,
      createdAt: createdAt is String? ? createdAt : this.createdAt,
    );
  }
}
