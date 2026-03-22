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

abstract class DemandeResponsableResponse implements _i1.SerializableModel {
  DemandeResponsableResponse._({
    required this.id,
    required this.userId,
    required this.structureType,
    required this.structureName,
    required this.structureCity,
    this.structureAddress,
    this.structureWebsite,
    this.structureSiret,
    this.structurePhone,
    this.contactRole,
    this.description,
    this.socialLinks,
    this.professionalEmail,
    required this.status,
    required this.createdAt,
    this.userName,
    this.userEmail,
  });

  factory DemandeResponsableResponse({
    required String id,
    required String userId,
    required String structureType,
    required String structureName,
    required String structureCity,
    String? structureAddress,
    String? structureWebsite,
    String? structureSiret,
    String? structurePhone,
    String? contactRole,
    String? description,
    String? socialLinks,
    String? professionalEmail,
    required String status,
    required String createdAt,
    String? userName,
    String? userEmail,
  }) = _DemandeResponsableResponseImpl;

  factory DemandeResponsableResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DemandeResponsableResponse(
      id: jsonSerialization['id'] as String,
      userId: jsonSerialization['userId'] as String,
      structureType: jsonSerialization['structureType'] as String,
      structureName: jsonSerialization['structureName'] as String,
      structureCity: jsonSerialization['structureCity'] as String,
      structureAddress: jsonSerialization['structureAddress'] as String?,
      structureWebsite: jsonSerialization['structureWebsite'] as String?,
      structureSiret: jsonSerialization['structureSiret'] as String?,
      structurePhone: jsonSerialization['structurePhone'] as String?,
      contactRole: jsonSerialization['contactRole'] as String?,
      description: jsonSerialization['description'] as String?,
      socialLinks: jsonSerialization['socialLinks'] as String?,
      professionalEmail: jsonSerialization['professionalEmail'] as String?,
      status: jsonSerialization['status'] as String,
      createdAt: jsonSerialization['createdAt'] as String,
      userName: jsonSerialization['userName'] as String?,
      userEmail: jsonSerialization['userEmail'] as String?,
    );
  }

  String id;

  String userId;

  String structureType;

  String structureName;

  String structureCity;

  String? structureAddress;

  String? structureWebsite;

  String? structureSiret;

  String? structurePhone;

  String? contactRole;

  String? description;

  String? socialLinks;

  String? professionalEmail;

  String status;

  String createdAt;

  String? userName;

  String? userEmail;

  /// Returns a shallow copy of this [DemandeResponsableResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DemandeResponsableResponse copyWith({
    String? id,
    String? userId,
    String? structureType,
    String? structureName,
    String? structureCity,
    String? structureAddress,
    String? structureWebsite,
    String? structureSiret,
    String? structurePhone,
    String? contactRole,
    String? description,
    String? socialLinks,
    String? professionalEmail,
    String? status,
    String? createdAt,
    String? userName,
    String? userEmail,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DemandeResponsableResponse',
      'id': id,
      'userId': userId,
      'structureType': structureType,
      'structureName': structureName,
      'structureCity': structureCity,
      if (structureAddress != null) 'structureAddress': structureAddress,
      if (structureWebsite != null) 'structureWebsite': structureWebsite,
      if (structureSiret != null) 'structureSiret': structureSiret,
      if (structurePhone != null) 'structurePhone': structurePhone,
      if (contactRole != null) 'contactRole': contactRole,
      if (description != null) 'description': description,
      if (socialLinks != null) 'socialLinks': socialLinks,
      if (professionalEmail != null) 'professionalEmail': professionalEmail,
      'status': status,
      'createdAt': createdAt,
      if (userName != null) 'userName': userName,
      if (userEmail != null) 'userEmail': userEmail,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DemandeResponsableResponseImpl extends DemandeResponsableResponse {
  _DemandeResponsableResponseImpl({
    required String id,
    required String userId,
    required String structureType,
    required String structureName,
    required String structureCity,
    String? structureAddress,
    String? structureWebsite,
    String? structureSiret,
    String? structurePhone,
    String? contactRole,
    String? description,
    String? socialLinks,
    String? professionalEmail,
    required String status,
    required String createdAt,
    String? userName,
    String? userEmail,
  }) : super._(
         id: id,
         userId: userId,
         structureType: structureType,
         structureName: structureName,
         structureCity: structureCity,
         structureAddress: structureAddress,
         structureWebsite: structureWebsite,
         structureSiret: structureSiret,
         structurePhone: structurePhone,
         contactRole: contactRole,
         description: description,
         socialLinks: socialLinks,
         professionalEmail: professionalEmail,
         status: status,
         createdAt: createdAt,
         userName: userName,
         userEmail: userEmail,
       );

  /// Returns a shallow copy of this [DemandeResponsableResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DemandeResponsableResponse copyWith({
    String? id,
    String? userId,
    String? structureType,
    String? structureName,
    String? structureCity,
    Object? structureAddress = _Undefined,
    Object? structureWebsite = _Undefined,
    Object? structureSiret = _Undefined,
    Object? structurePhone = _Undefined,
    Object? contactRole = _Undefined,
    Object? description = _Undefined,
    Object? socialLinks = _Undefined,
    Object? professionalEmail = _Undefined,
    String? status,
    String? createdAt,
    Object? userName = _Undefined,
    Object? userEmail = _Undefined,
  }) {
    return DemandeResponsableResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      structureType: structureType ?? this.structureType,
      structureName: structureName ?? this.structureName,
      structureCity: structureCity ?? this.structureCity,
      structureAddress: structureAddress is String?
          ? structureAddress
          : this.structureAddress,
      structureWebsite: structureWebsite is String?
          ? structureWebsite
          : this.structureWebsite,
      structureSiret: structureSiret is String?
          ? structureSiret
          : this.structureSiret,
      structurePhone: structurePhone is String?
          ? structurePhone
          : this.structurePhone,
      contactRole: contactRole is String? ? contactRole : this.contactRole,
      description: description is String? ? description : this.description,
      socialLinks: socialLinks is String? ? socialLinks : this.socialLinks,
      professionalEmail: professionalEmail is String?
          ? professionalEmail
          : this.professionalEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      userName: userName is String? ? userName : this.userName,
      userEmail: userEmail is String? ? userEmail : this.userEmail,
    );
  }
}
