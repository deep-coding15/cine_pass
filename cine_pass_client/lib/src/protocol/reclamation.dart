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
import 'protocol.dart' as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;

/// Réclamation client (lié à un événement / structure).
abstract class Reclamation extends _i1.CinePassRow
    implements _i2.SerializableModel {
  Reclamation._({
    _i2.UuidValue? id,
    super.createdAt,
    this.userId,
    this.eventId,
    this.structureId,
    required this.sujet,
    required this.message,
    String? statut,
    this.lastResponseFrom,
    this.lastResponse,
    DateTime? updatedAt,
  }) : id = id ?? const _i2.Uuid().v4obj(),
       statut = statut ?? 'ouverte',
       updatedAt = updatedAt ?? DateTime.now();

  factory Reclamation({
    _i2.UuidValue? id,
    DateTime? createdAt,
    int? userId,
    _i2.UuidValue? eventId,
    _i2.UuidValue? structureId,
    required String sujet,
    required String message,
    String? statut,
    String? lastResponseFrom,
    String? lastResponse,
    DateTime? updatedAt,
  }) = _ReclamationImpl;

  factory Reclamation.fromJson(Map<String, dynamic> jsonSerialization) {
    return Reclamation(
      id: jsonSerialization['id'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      userId: jsonSerialization['userId'] as int?,
      eventId: jsonSerialization['eventId'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(jsonSerialization['eventId']),
      structureId: jsonSerialization['structureId'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(
              jsonSerialization['structureId'],
            ),
      sujet: jsonSerialization['sujet'] as String,
      message: jsonSerialization['message'] as String,
      statut: jsonSerialization['statut'] as String?,
      lastResponseFrom: jsonSerialization['lastResponseFrom'] as String?,
      lastResponse: jsonSerialization['lastResponse'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The id of the object.
  _i2.UuidValue id;

  int? userId;

  _i2.UuidValue? eventId;

  _i2.UuidValue? structureId;

  String sujet;

  String message;

  String statut;

  String? lastResponseFrom;

  String? lastResponse;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Reclamation]
  /// with some or all fields replaced by the given arguments.
  @override
  @_i2.useResult
  Reclamation copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    int? userId,
    _i2.UuidValue? eventId,
    _i2.UuidValue? structureId,
    String? sujet,
    String? message,
    String? statut,
    String? lastResponseFrom,
    String? lastResponse,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Reclamation',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      if (userId != null) 'userId': userId,
      if (eventId != null) 'eventId': eventId?.toJson(),
      if (structureId != null) 'structureId': structureId?.toJson(),
      'sujet': sujet,
      'message': message,
      'statut': statut,
      if (lastResponseFrom != null) 'lastResponseFrom': lastResponseFrom,
      if (lastResponse != null) 'lastResponse': lastResponse,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i2.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReclamationImpl extends Reclamation {
  _ReclamationImpl({
    _i2.UuidValue? id,
    DateTime? createdAt,
    int? userId,
    _i2.UuidValue? eventId,
    _i2.UuidValue? structureId,
    required String sujet,
    required String message,
    String? statut,
    String? lastResponseFrom,
    String? lastResponse,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         createdAt: createdAt,
         userId: userId,
         eventId: eventId,
         structureId: structureId,
         sujet: sujet,
         message: message,
         statut: statut,
         lastResponseFrom: lastResponseFrom,
         lastResponse: lastResponse,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Reclamation]
  /// with some or all fields replaced by the given arguments.
  @_i2.useResult
  @override
  Reclamation copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    Object? userId = _Undefined,
    Object? eventId = _Undefined,
    Object? structureId = _Undefined,
    String? sujet,
    String? message,
    String? statut,
    Object? lastResponseFrom = _Undefined,
    Object? lastResponse = _Undefined,
    DateTime? updatedAt,
  }) {
    return Reclamation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId is int? ? userId : this.userId,
      eventId: eventId is _i2.UuidValue? ? eventId : this.eventId,
      structureId: structureId is _i2.UuidValue?
          ? structureId
          : this.structureId,
      sujet: sujet ?? this.sujet,
      message: message ?? this.message,
      statut: statut ?? this.statut,
      lastResponseFrom: lastResponseFrom is String?
          ? lastResponseFrom
          : this.lastResponseFrom,
      lastResponse: lastResponse is String? ? lastResponse : this.lastResponse,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
