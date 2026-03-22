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
import 'package:cine_pass_client/src/protocol/protocol.dart' as _i3;

/// Événement (concert, théâtre, etc.).
abstract class Evenement extends _i1.CinePassRow
    implements _i2.SerializableModel {
  Evenement._({
    _i2.UuidValue? id,
    super.createdAt,
    required this.titre,
    required this.categorie,
    String? event_type,
    this.event_subtype,
    this.custom_type_label,
    this.event_language,
    this.description,
    required this.lieu,
    this.adresse,
    required this.ville,
    required this.eventDate,
    required this.eventTime,
    required this.placesTotal,
    required this.prixBase,
    this.posterColor,
    this.posterUrl,
    this.availableOptions,
    this.structureId,
    bool? archived,
  }) : id = id ?? const _i2.Uuid().v4obj(),
       event_type = event_type ?? 'AUTRE',
       archived = archived ?? false;

  factory Evenement({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required String titre,
    required String categorie,
    String? event_type,
    String? event_subtype,
    String? custom_type_label,
    String? event_language,
    String? description,
    required String lieu,
    String? adresse,
    required String ville,
    required DateTime eventDate,
    required DateTime eventTime,
    required int placesTotal,
    required double prixBase,
    int? posterColor,
    String? posterUrl,
    List<String>? availableOptions,
    _i2.UuidValue? structureId,
    bool? archived,
  }) = _EvenementImpl;

  factory Evenement.fromJson(Map<String, dynamic> jsonSerialization) {
    return Evenement(
      id: jsonSerialization['id'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      titre: jsonSerialization['titre'] as String,
      categorie: jsonSerialization['categorie'] as String,
      event_type: jsonSerialization['event_type'] as String?,
      event_subtype: jsonSerialization['event_subtype'] as String?,
      custom_type_label: jsonSerialization['custom_type_label'] as String?,
      event_language: jsonSerialization['event_language'] as String?,
      description: jsonSerialization['description'] as String?,
      lieu: jsonSerialization['lieu'] as String,
      adresse: jsonSerialization['adresse'] as String?,
      ville: jsonSerialization['ville'] as String,
      eventDate: _i2.DateTimeJsonExtension.fromJson(
        jsonSerialization['eventDate'],
      ),
      eventTime: _i2.DateTimeJsonExtension.fromJson(
        jsonSerialization['eventTime'],
      ),
      placesTotal: jsonSerialization['placesTotal'] as int,
      prixBase: (jsonSerialization['prixBase'] as num).toDouble(),
      posterColor: jsonSerialization['posterColor'] as int?,
      posterUrl: jsonSerialization['posterUrl'] as String?,
      availableOptions: jsonSerialization['availableOptions'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['availableOptions'],
            ),
      structureId: jsonSerialization['structureId'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(
              jsonSerialization['structureId'],
            ),
      archived: jsonSerialization['archived'] == null
          ? null
          : _i2.BoolJsonExtension.fromJson(jsonSerialization['archived']),
    );
  }

  /// The id of the object.
  _i2.UuidValue id;

  String titre;

  String categorie;

  /// Colonnes alignées sur schema/cine_pass_schema.sql (snake_case en base).
  String event_type;

  String? event_subtype;

  String? custom_type_label;

  String? event_language;

  String? description;

  String lieu;

  String? adresse;

  String ville;

  DateTime eventDate;

  DateTime eventTime;

  int placesTotal;

  double prixBase;

  int? posterColor;

  String? posterUrl;

  List<String>? availableOptions;

  _i2.UuidValue? structureId;

  bool archived;

  /// Returns a shallow copy of this [Evenement]
  /// with some or all fields replaced by the given arguments.
  @override
  @_i2.useResult
  Evenement copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    String? titre,
    String? categorie,
    String? event_type,
    String? event_subtype,
    String? custom_type_label,
    String? event_language,
    String? description,
    String? lieu,
    String? adresse,
    String? ville,
    DateTime? eventDate,
    DateTime? eventTime,
    int? placesTotal,
    double? prixBase,
    int? posterColor,
    String? posterUrl,
    List<String>? availableOptions,
    _i2.UuidValue? structureId,
    bool? archived,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Evenement',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'titre': titre,
      'categorie': categorie,
      'event_type': event_type,
      if (event_subtype != null) 'event_subtype': event_subtype,
      if (custom_type_label != null) 'custom_type_label': custom_type_label,
      if (event_language != null) 'event_language': event_language,
      if (description != null) 'description': description,
      'lieu': lieu,
      if (adresse != null) 'adresse': adresse,
      'ville': ville,
      'eventDate': eventDate.toJson(),
      'eventTime': eventTime.toJson(),
      'placesTotal': placesTotal,
      'prixBase': prixBase,
      if (posterColor != null) 'posterColor': posterColor,
      if (posterUrl != null) 'posterUrl': posterUrl,
      if (availableOptions != null)
        'availableOptions': availableOptions?.toJson(),
      if (structureId != null) 'structureId': structureId?.toJson(),
      'archived': archived,
    };
  }

  @override
  String toString() {
    return _i2.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EvenementImpl extends Evenement {
  _EvenementImpl({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required String titre,
    required String categorie,
    String? event_type,
    String? event_subtype,
    String? custom_type_label,
    String? event_language,
    String? description,
    required String lieu,
    String? adresse,
    required String ville,
    required DateTime eventDate,
    required DateTime eventTime,
    required int placesTotal,
    required double prixBase,
    int? posterColor,
    String? posterUrl,
    List<String>? availableOptions,
    _i2.UuidValue? structureId,
    bool? archived,
  }) : super._(
         id: id,
         createdAt: createdAt,
         titre: titre,
         categorie: categorie,
         event_type: event_type,
         event_subtype: event_subtype,
         custom_type_label: custom_type_label,
         event_language: event_language,
         description: description,
         lieu: lieu,
         adresse: adresse,
         ville: ville,
         eventDate: eventDate,
         eventTime: eventTime,
         placesTotal: placesTotal,
         prixBase: prixBase,
         posterColor: posterColor,
         posterUrl: posterUrl,
         availableOptions: availableOptions,
         structureId: structureId,
         archived: archived,
       );

  /// Returns a shallow copy of this [Evenement]
  /// with some or all fields replaced by the given arguments.
  @_i2.useResult
  @override
  Evenement copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    String? titre,
    String? categorie,
    String? event_type,
    Object? event_subtype = _Undefined,
    Object? custom_type_label = _Undefined,
    Object? event_language = _Undefined,
    Object? description = _Undefined,
    String? lieu,
    Object? adresse = _Undefined,
    String? ville,
    DateTime? eventDate,
    DateTime? eventTime,
    int? placesTotal,
    double? prixBase,
    Object? posterColor = _Undefined,
    Object? posterUrl = _Undefined,
    Object? availableOptions = _Undefined,
    Object? structureId = _Undefined,
    bool? archived,
  }) {
    return Evenement(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      titre: titre ?? this.titre,
      categorie: categorie ?? this.categorie,
      event_type: event_type ?? this.event_type,
      event_subtype: event_subtype is String?
          ? event_subtype
          : this.event_subtype,
      custom_type_label: custom_type_label is String?
          ? custom_type_label
          : this.custom_type_label,
      event_language: event_language is String?
          ? event_language
          : this.event_language,
      description: description is String? ? description : this.description,
      lieu: lieu ?? this.lieu,
      adresse: adresse is String? ? adresse : this.adresse,
      ville: ville ?? this.ville,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      placesTotal: placesTotal ?? this.placesTotal,
      prixBase: prixBase ?? this.prixBase,
      posterColor: posterColor is int? ? posterColor : this.posterColor,
      posterUrl: posterUrl is String? ? posterUrl : this.posterUrl,
      availableOptions: availableOptions is List<String>?
          ? availableOptions
          : this.availableOptions?.map((e0) => e0).toList(),
      structureId: structureId is _i2.UuidValue?
          ? structureId
          : this.structureId,
      archived: archived ?? this.archived,
    );
  }
}
