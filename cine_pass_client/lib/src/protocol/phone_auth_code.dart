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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class PhoneAuthCode implements _i1.SerializableModel {
  PhoneAuthCode._({
    this.id,
    required this.phone,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    int? attemptCount,
    this.consumedAt,
  }) : attemptCount = attemptCount ?? 0;

  factory PhoneAuthCode({
    int? id,
    required String phone,
    required String code,
    required DateTime createdAt,
    required DateTime expiresAt,
    int? attemptCount,
    DateTime? consumedAt,
  }) = _PhoneAuthCodeImpl;

  factory PhoneAuthCode.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhoneAuthCode(
      id: jsonSerialization['id'] as int?,
      phone: jsonSerialization['phone'] as String,
      code: jsonSerialization['code'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      attemptCount: jsonSerialization['attemptCount'] as int?,
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String phone;

  String code;

  DateTime createdAt;

  DateTime expiresAt;

  int attemptCount;

  DateTime? consumedAt;

  /// Returns a shallow copy of this [PhoneAuthCode]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhoneAuthCode copyWith({
    int? id,
    String? phone,
    String? code,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? attemptCount,
    DateTime? consumedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PhoneAuthCode',
      if (id != null) 'id': id,
      'phone': phone,
      'code': code,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'attemptCount': attemptCount,
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhoneAuthCodeImpl extends PhoneAuthCode {
  _PhoneAuthCodeImpl({
    int? id,
    required String phone,
    required String code,
    required DateTime createdAt,
    required DateTime expiresAt,
    int? attemptCount,
    DateTime? consumedAt,
  }) : super._(
         id: id,
         phone: phone,
         code: code,
         createdAt: createdAt,
         expiresAt: expiresAt,
         attemptCount: attemptCount,
         consumedAt: consumedAt,
       );

  /// Returns a shallow copy of this [PhoneAuthCode]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhoneAuthCode copyWith({
    Object? id = _Undefined,
    String? phone,
    String? code,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? attemptCount,
    Object? consumedAt = _Undefined,
  }) {
    return PhoneAuthCode(
      id: id is int? ? id : this.id,
      phone: phone ?? this.phone,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      attemptCount: attemptCount ?? this.attemptCount,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
    );
  }
}
