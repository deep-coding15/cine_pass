/* Generated for DemandeResponsableResponse - run "serverpod generate" to update. */
import 'package:serverpod/serverpod.dart' as _i1;

abstract class DemandeResponsableResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DemandeResponsableResponse._({
    required this.id,
    required this.userId,
    required this.structureType,
    required this.structureName,
    required this.structureCity,
    this.structureAddress,
    required this.status,
    required this.createdAt,
    this.userName,
  });

  factory DemandeResponsableResponse({
    required String id,
    required String userId,
    required String structureType,
    required String structureName,
    required String structureCity,
    String? structureAddress,
    required String status,
    required String createdAt,
    String? userName,
  }) = _DemandeResponsableResponseImpl;

  factory DemandeResponsableResponse.fromJson(Map<String, dynamic> json) {
    return DemandeResponsableResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      structureType: json['structureType'] as String,
      structureName: json['structureName'] as String,
      structureCity: json['structureCity'] as String,
      structureAddress: json['structureAddress'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      userName: json['userName'] as String?,
    );
  }

  String id;
  String userId;
  String structureType;
  String structureName;
  String structureCity;
  String? structureAddress;
  String status;
  String createdAt;
  String? userName;

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
      'status': status,
      'createdAt': createdAt,
      if (userName != null) 'userName': userName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() => toJson();

  @override
  String toString() => _i1.SerializationManager.encode(this);
}

class _DemandeResponsableResponseImpl extends DemandeResponsableResponse {
  _DemandeResponsableResponseImpl({
    required String id,
    required String userId,
    required String structureType,
    required String structureName,
    required String structureCity,
    String? structureAddress,
    required String status,
    required String createdAt,
    String? userName,
  }) : super._(
         id: id,
         userId: userId,
         structureType: structureType,
         structureName: structureName,
         structureCity: structureCity,
         structureAddress: structureAddress,
         status: status,
         createdAt: createdAt,
         userName: userName,
       );
}
