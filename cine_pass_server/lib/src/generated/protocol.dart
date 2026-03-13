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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i3;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i4;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i5;
import 'cine_pass/cinema_response.dart' as _i6;
import 'cine_pass/demande_responsable_response.dart' as _i7;
import 'cine_pass/event_response.dart' as _i8;
import 'cine_pass/film_response.dart' as _i9;
import 'cine_pass/rapport_ca_response.dart' as _i10;
import 'cine_pass/reservation_response.dart' as _i11;
import 'cine_pass/seance_response.dart' as _i12;
import 'cinema.dart' as _i13;
import 'evenement.dart' as _i14;
import 'film.dart' as _i15;
import 'seance.dart' as _i16;
import 'cine_pass_row.dart' as _i17;
import 'greetings/greeting.dart' as _i18;
import 'phone_auth_code.dart' as _i19;
import 'salle.dart' as _i20;
import 'siege.dart' as _i21;
import 'structure.dart' as _i22;
import 'package:cine_pass_server/src/generated/cine_pass/film_response.dart'
    as _i23;
import 'package:cine_pass_server/src/generated/cine_pass/seance_response.dart'
    as _i24;
import 'package:cine_pass_server/src/generated/cine_pass/cinema_response.dart'
    as _i25;
import 'package:cine_pass_server/src/generated/salle.dart' as _i26;
import 'package:cine_pass_server/src/generated/cine_pass/event_response.dart'
    as _i27;
import 'package:cine_pass_server/src/generated/structure.dart' as _i28;
import 'package:cine_pass_server/src/generated/cine_pass/demande_responsable_response.dart'
    as _i29;
import 'package:cine_pass_server/src/generated/cine_pass/reservation_response.dart'
    as _i30;
export 'cine_pass/cinema_response.dart';
export 'cine_pass/demande_responsable_response.dart';
export 'cine_pass/event_response.dart';
export 'cine_pass/film_response.dart';
export 'cine_pass/rapport_ca_response.dart';
export 'cine_pass/reservation_response.dart';
export 'cine_pass/seance_response.dart';
export 'cinema.dart';
export 'evenement.dart';
export 'film.dart';
export 'seance.dart';
export 'cine_pass_row.dart';
export 'greetings/greeting.dart';
export 'phone_auth_code.dart';
export 'salle.dart';
export 'siege.dart';
export 'structure.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'cine_pass_cinema',
      dartName: 'Cinema',
      schema: 'public',
      module: 'cine_pass',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'nom',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'ville',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'adresse',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'codePostal',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'cine_pass_cinema_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: false,
    ),
    _i2.TableDefinition(
      name: 'cine_pass_evenement',
      dartName: 'Evenement',
      schema: 'public',
      module: 'cine_pass',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'titre',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'categorie',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'lieu',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'adresse',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'ville',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'eventDate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'eventTime',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'placesTotal',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'prixBase',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'posterColor',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'posterUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'availableOptions',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
        _i2.ColumnDefinition(
          name: 'structureId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'cine_pass_evenement_fk_0',
          columns: ['structureId'],
          referenceTable: 'cine_pass_structure',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'cine_pass_evenement_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: false,
    ),
    _i2.TableDefinition(
      name: 'cine_pass_film',
      dartName: 'Film',
      schema: 'public',
      module: 'cine_pass',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'titre',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'genre',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'dureeMinutes',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'synopsis',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'directeur',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'casting',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'posterColor',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'posterUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'dateSortie',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'dateFin',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'audience',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'cine_pass_film_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: false,
    ),
    _i2.TableDefinition(
      name: 'cine_pass_salle',
      dartName: 'Salle',
      schema: 'public',
      module: 'cine_pass',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'cinemaId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'nom',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'capacite',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'cine_pass_salle_fk_0',
          columns: ['cinemaId'],
          referenceTable: 'cine_pass_cinema',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'cine_pass_salle_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: false,
    ),
    _i2.TableDefinition(
      name: 'cine_pass_seance',
      dartName: 'Seance',
      schema: 'public',
      module: 'cine_pass',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'filmId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'salleId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'debutAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'finAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'format',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'VF\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'2D\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'prixBase',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'availableOptions',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'cine_pass_seance_fk_0',
          columns: ['filmId'],
          referenceTable: 'cine_pass_film',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'cine_pass_seance_fk_1',
          columns: ['salleId'],
          referenceTable: 'cine_pass_salle',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'cine_pass_seance_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: false,
    ),
    _i2.TableDefinition(
      name: 'cine_pass_siege',
      dartName: 'Siege',
      schema: 'public',
      module: 'cine_pass',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'salleId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'rangee',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'numero',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'cine_pass_siege_fk_0',
          columns: ['salleId'],
          referenceTable: 'cine_pass_salle',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'cine_pass_siege_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: false,
    ),
    _i2.TableDefinition(
      name: 'cine_pass_structure',
      dartName: 'Structure',
      schema: 'public',
      module: 'cine_pass',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'city',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'address',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'website',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'phone',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'cinemaId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'cine_pass_structure_fk_0',
          columns: ['cinemaId'],
          referenceTable: 'cine_pass_cinema',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'cine_pass_structure_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'cine_pass_structure_type_city_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'type',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'city',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: false,
    ),
    _i2.TableDefinition(
      name: 'phone_auth_code',
      dartName: 'PhoneAuthCode',
      schema: 'public',
      module: 'cine_pass',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'phone_auth_code_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'phone',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'code',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'expiresAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'attemptCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _i2.ColumnDefinition(
          name: 'consumedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'phone_auth_code_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i5.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i6.CinemaResponse) {
      return _i6.CinemaResponse.fromJson(data) as T;
    }
    if (t == _i7.DemandeResponsableResponse) {
      return _i7.DemandeResponsableResponse.fromJson(data) as T;
    }
    if (t == _i8.EventResponse) {
      return _i8.EventResponse.fromJson(data) as T;
    }
    if (t == _i9.FilmResponse) {
      return _i9.FilmResponse.fromJson(data) as T;
    }
    if (t == _i10.RapportCAResponse) {
      return _i10.RapportCAResponse.fromJson(data) as T;
    }
    if (t == _i11.ReservationResponse) {
      return _i11.ReservationResponse.fromJson(data) as T;
    }
    if (t == _i12.SeanceResponse) {
      return _i12.SeanceResponse.fromJson(data) as T;
    }
    if (t == _i13.Cinema) {
      return _i13.Cinema.fromJson(data) as T;
    }
    if (t == _i14.Evenement) {
      return _i14.Evenement.fromJson(data) as T;
    }
    if (t == _i15.Film) {
      return _i15.Film.fromJson(data) as T;
    }
    if (t == _i16.Seance) {
      return _i16.Seance.fromJson(data) as T;
    }
    if (t == _i17.CinePassRow) {
      return _i17.CinePassRow.fromJson(data) as T;
    }
    if (t == _i18.Greeting) {
      return _i18.Greeting.fromJson(data) as T;
    }
    if (t == _i19.PhoneAuthCode) {
      return _i19.PhoneAuthCode.fromJson(data) as T;
    }
    if (t == _i20.Salle) {
      return _i20.Salle.fromJson(data) as T;
    }
    if (t == _i21.Siege) {
      return _i21.Siege.fromJson(data) as T;
    }
    if (t == _i22.Structure) {
      return _i22.Structure.fromJson(data) as T;
    }
    if (t == _i1.getType<_i6.CinemaResponse?>()) {
      return (data != null ? _i6.CinemaResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.DemandeResponsableResponse?>()) {
      return (data != null
              ? _i7.DemandeResponsableResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i8.EventResponse?>()) {
      return (data != null ? _i8.EventResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.FilmResponse?>()) {
      return (data != null ? _i9.FilmResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.RapportCAResponse?>()) {
      return (data != null ? _i10.RapportCAResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ReservationResponse?>()) {
      return (data != null ? _i11.ReservationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.SeanceResponse?>()) {
      return (data != null ? _i12.SeanceResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Cinema?>()) {
      return (data != null ? _i13.Cinema.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Evenement?>()) {
      return (data != null ? _i14.Evenement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.Film?>()) {
      return (data != null ? _i15.Film.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.Seance?>()) {
      return (data != null ? _i16.Seance.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.CinePassRow?>()) {
      return (data != null ? _i17.CinePassRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.Greeting?>()) {
      return (data != null ? _i18.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.PhoneAuthCode?>()) {
      return (data != null ? _i19.PhoneAuthCode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.Salle?>()) {
      return (data != null ? _i20.Salle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.Siege?>()) {
      return (data != null ? _i21.Siege.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.Structure?>()) {
      return (data != null ? _i22.Structure.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i23.FilmResponse>) {
      return (data as List)
              .map((e) => deserialize<_i23.FilmResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i24.SeanceResponse>) {
      return (data as List)
              .map((e) => deserialize<_i24.SeanceResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.CinemaResponse>) {
      return (data as List)
              .map((e) => deserialize<_i25.CinemaResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i26.Salle>) {
      return (data as List).map((e) => deserialize<_i26.Salle>(e)).toList()
          as T;
    }
    if (t == List<_i27.EventResponse>) {
      return (data as List)
              .map((e) => deserialize<_i27.EventResponse>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i28.Structure>) {
      return (data as List).map((e) => deserialize<_i28.Structure>(e)).toList()
          as T;
    }
    if (t == List<_i29.DemandeResponsableResponse>) {
      return (data as List)
              .map((e) => deserialize<_i29.DemandeResponsableResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i30.ReservationResponse>) {
      return (data as List)
              .map((e) => deserialize<_i30.ReservationResponse>(e))
              .toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i5.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i6.CinemaResponse => 'CinemaResponse',
      _i7.DemandeResponsableResponse => 'DemandeResponsableResponse',
      _i8.EventResponse => 'EventResponse',
      _i9.FilmResponse => 'FilmResponse',
      _i10.RapportCAResponse => 'RapportCAResponse',
      _i11.ReservationResponse => 'ReservationResponse',
      _i12.SeanceResponse => 'SeanceResponse',
      _i13.Cinema => 'Cinema',
      _i14.Evenement => 'Evenement',
      _i15.Film => 'Film',
      _i16.Seance => 'Seance',
      _i17.CinePassRow => 'CinePassRow',
      _i18.Greeting => 'Greeting',
      _i19.PhoneAuthCode => 'PhoneAuthCode',
      _i20.Salle => 'Salle',
      _i21.Siege => 'Siege',
      _i22.Structure => 'Structure',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('cine_pass.', '');
    }

    switch (data) {
      case _i6.CinemaResponse():
        return 'CinemaResponse';
      case _i7.DemandeResponsableResponse():
        return 'DemandeResponsableResponse';
      case _i8.EventResponse():
        return 'EventResponse';
      case _i9.FilmResponse():
        return 'FilmResponse';
      case _i10.RapportCAResponse():
        return 'RapportCAResponse';
      case _i11.ReservationResponse():
        return 'ReservationResponse';
      case _i12.SeanceResponse():
        return 'SeanceResponse';
      case _i13.Cinema():
        return 'Cinema';
      case _i14.Evenement():
        return 'Evenement';
      case _i15.Film():
        return 'Film';
      case _i16.Seance():
        return 'Seance';
      case _i17.CinePassRow():
        return 'CinePassRow';
      case _i18.Greeting():
        return 'Greeting';
      case _i19.PhoneAuthCode():
        return 'PhoneAuthCode';
      case _i20.Salle():
        return 'Salle';
      case _i21.Siege():
        return 'Siege';
      case _i22.Structure():
        return 'Structure';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i5.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CinemaResponse') {
      return deserialize<_i6.CinemaResponse>(data['data']);
    }
    if (dataClassName == 'DemandeResponsableResponse') {
      return deserialize<_i7.DemandeResponsableResponse>(data['data']);
    }
    if (dataClassName == 'EventResponse') {
      return deserialize<_i8.EventResponse>(data['data']);
    }
    if (dataClassName == 'FilmResponse') {
      return deserialize<_i9.FilmResponse>(data['data']);
    }
    if (dataClassName == 'RapportCAResponse') {
      return deserialize<_i10.RapportCAResponse>(data['data']);
    }
    if (dataClassName == 'ReservationResponse') {
      return deserialize<_i11.ReservationResponse>(data['data']);
    }
    if (dataClassName == 'SeanceResponse') {
      return deserialize<_i12.SeanceResponse>(data['data']);
    }
    if (dataClassName == 'Cinema') {
      return deserialize<_i13.Cinema>(data['data']);
    }
    if (dataClassName == 'Evenement') {
      return deserialize<_i14.Evenement>(data['data']);
    }
    if (dataClassName == 'Film') {
      return deserialize<_i15.Film>(data['data']);
    }
    if (dataClassName == 'Seance') {
      return deserialize<_i16.Seance>(data['data']);
    }
    if (dataClassName == 'CinePassRow') {
      return deserialize<_i17.CinePassRow>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i18.Greeting>(data['data']);
    }
    if (dataClassName == 'PhoneAuthCode') {
      return deserialize<_i19.PhoneAuthCode>(data['data']);
    }
    if (dataClassName == 'Salle') {
      return deserialize<_i20.Salle>(data['data']);
    }
    if (dataClassName == 'Siege') {
      return deserialize<_i21.Siege>(data['data']);
    }
    if (dataClassName == 'Structure') {
      return deserialize<_i22.Structure>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i4.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i5.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i5.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i13.Cinema:
        return _i13.Cinema.t;
      case _i14.Evenement:
        return _i14.Evenement.t;
      case _i15.Film:
        return _i15.Film.t;
      case _i16.Seance:
        return _i16.Seance.t;
      case _i19.PhoneAuthCode:
        return _i19.PhoneAuthCode.t;
      case _i20.Salle:
        return _i20.Salle.t;
      case _i21.Siege:
        return _i21.Siege.t;
      case _i22.Structure:
        return _i22.Structure.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'cine_pass';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i5.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
