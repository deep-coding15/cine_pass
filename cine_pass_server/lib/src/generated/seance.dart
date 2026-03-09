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
import 'package:serverpod/serverpod.dart' as _i2;
import 'package:cine_pass_server/src/generated/protocol.dart' as _i3;

/// Séance (film + salle + créneau).
abstract class Seance extends _i1.CinePassRow
    implements _i2.TableRow<_i2.UuidValue>, _i2.ProtocolSerialization {
  Seance._({
    _i2.UuidValue? id,
    super.createdAt,
    required this.filmId,
    required this.salleId,
    required this.debutAt,
    this.finAt,
    String? format,
    String? type,
    required this.prixBase,
    this.availableOptions,
  }) : id = id ?? const _i2.Uuid().v4obj(),
       format = format ?? 'VF',
       type = type ?? '2D';

  factory Seance({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required _i2.UuidValue filmId,
    required _i2.UuidValue salleId,
    required DateTime debutAt,
    DateTime? finAt,
    String? format,
    String? type,
    required double prixBase,
    List<String>? availableOptions,
  }) = _SeanceImpl;

  factory Seance.fromJson(Map<String, dynamic> jsonSerialization) {
    return Seance(
      id: jsonSerialization['id'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      filmId: _i2.UuidValueJsonExtension.fromJson(jsonSerialization['filmId']),
      salleId: _i2.UuidValueJsonExtension.fromJson(
        jsonSerialization['salleId'],
      ),
      debutAt: _i2.DateTimeJsonExtension.fromJson(jsonSerialization['debutAt']),
      finAt: jsonSerialization['finAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['finAt']),
      format: jsonSerialization['format'] as String?,
      type: jsonSerialization['type'] as String?,
      prixBase: (jsonSerialization['prixBase'] as num).toDouble(),
      availableOptions: jsonSerialization['availableOptions'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['availableOptions'],
            ),
    );
  }

  static final t = SeanceTable();

  static const db = SeanceRepository._();

  @override
  _i2.UuidValue id;

  _i2.UuidValue filmId;

  _i2.UuidValue salleId;

  DateTime debutAt;

  DateTime? finAt;

  String format;

  String type;

  double prixBase;

  List<String>? availableOptions;

  @override
  _i2.Table<_i2.UuidValue> get table => t;

  /// Returns a shallow copy of this [Seance]
  /// with some or all fields replaced by the given arguments.
  @override
  @_i2.useResult
  Seance copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    _i2.UuidValue? filmId,
    _i2.UuidValue? salleId,
    DateTime? debutAt,
    DateTime? finAt,
    String? format,
    String? type,
    double? prixBase,
    List<String>? availableOptions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Seance',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'filmId': filmId.toJson(),
      'salleId': salleId.toJson(),
      'debutAt': debutAt.toJson(),
      if (finAt != null) 'finAt': finAt?.toJson(),
      'format': format,
      'type': type,
      'prixBase': prixBase,
      if (availableOptions != null)
        'availableOptions': availableOptions?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Seance',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'filmId': filmId.toJson(),
      'salleId': salleId.toJson(),
      'debutAt': debutAt.toJson(),
      if (finAt != null) 'finAt': finAt?.toJson(),
      'format': format,
      'type': type,
      'prixBase': prixBase,
      if (availableOptions != null)
        'availableOptions': availableOptions?.toJson(),
    };
  }

  static SeanceInclude include() {
    return SeanceInclude._();
  }

  static SeanceIncludeList includeList({
    _i2.WhereExpressionBuilder<SeanceTable>? where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<SeanceTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<SeanceTable>? orderByList,
    SeanceInclude? include,
  }) {
    return SeanceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Seance.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Seance.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i2.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SeanceImpl extends Seance {
  _SeanceImpl({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required _i2.UuidValue filmId,
    required _i2.UuidValue salleId,
    required DateTime debutAt,
    DateTime? finAt,
    String? format,
    String? type,
    required double prixBase,
    List<String>? availableOptions,
  }) : super._(
         id: id,
         createdAt: createdAt,
         filmId: filmId,
         salleId: salleId,
         debutAt: debutAt,
         finAt: finAt,
         format: format,
         type: type,
         prixBase: prixBase,
         availableOptions: availableOptions,
       );

  /// Returns a shallow copy of this [Seance]
  /// with some or all fields replaced by the given arguments.
  @_i2.useResult
  @override
  Seance copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    _i2.UuidValue? filmId,
    _i2.UuidValue? salleId,
    DateTime? debutAt,
    Object? finAt = _Undefined,
    String? format,
    String? type,
    double? prixBase,
    Object? availableOptions = _Undefined,
  }) {
    return Seance(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      filmId: filmId ?? this.filmId,
      salleId: salleId ?? this.salleId,
      debutAt: debutAt ?? this.debutAt,
      finAt: finAt is DateTime? ? finAt : this.finAt,
      format: format ?? this.format,
      type: type ?? this.type,
      prixBase: prixBase ?? this.prixBase,
      availableOptions: availableOptions is List<String>?
          ? availableOptions
          : this.availableOptions?.map((e0) => e0).toList(),
    );
  }
}

class SeanceUpdateTable extends _i2.UpdateTable<SeanceTable> {
  SeanceUpdateTable(super.table);

  _i2.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i2.ColumnValue(
        table.createdAt,
        value,
      );

  _i2.ColumnValue<_i2.UuidValue, _i2.UuidValue> filmId(_i2.UuidValue value) =>
      _i2.ColumnValue(
        table.filmId,
        value,
      );

  _i2.ColumnValue<_i2.UuidValue, _i2.UuidValue> salleId(_i2.UuidValue value) =>
      _i2.ColumnValue(
        table.salleId,
        value,
      );

  _i2.ColumnValue<DateTime, DateTime> debutAt(DateTime value) =>
      _i2.ColumnValue(
        table.debutAt,
        value,
      );

  _i2.ColumnValue<DateTime, DateTime> finAt(DateTime? value) => _i2.ColumnValue(
    table.finAt,
    value,
  );

  _i2.ColumnValue<String, String> format(String value) => _i2.ColumnValue(
    table.format,
    value,
  );

  _i2.ColumnValue<String, String> type(String value) => _i2.ColumnValue(
    table.type,
    value,
  );

  _i2.ColumnValue<double, double> prixBase(double value) => _i2.ColumnValue(
    table.prixBase,
    value,
  );

  _i2.ColumnValue<List<String>, List<String>> availableOptions(
    List<String>? value,
  ) => _i2.ColumnValue(
    table.availableOptions,
    value,
  );
}

class SeanceTable extends _i2.Table<_i2.UuidValue> {
  SeanceTable({super.tableRelation}) : super(tableName: 'cine_pass_seance') {
    updateTable = SeanceUpdateTable(this);
    createdAt = _i2.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    filmId = _i2.ColumnUuid(
      'filmId',
      this,
    );
    salleId = _i2.ColumnUuid(
      'salleId',
      this,
    );
    debutAt = _i2.ColumnDateTime(
      'debutAt',
      this,
    );
    finAt = _i2.ColumnDateTime(
      'finAt',
      this,
    );
    format = _i2.ColumnString(
      'format',
      this,
      hasDefault: true,
    );
    type = _i2.ColumnString(
      'type',
      this,
      hasDefault: true,
    );
    prixBase = _i2.ColumnDouble(
      'prixBase',
      this,
    );
    availableOptions = _i2.ColumnSerializable<List<String>>(
      'availableOptions',
      this,
    );
  }

  late final SeanceUpdateTable updateTable;

  late final _i2.ColumnDateTime createdAt;

  late final _i2.ColumnUuid filmId;

  late final _i2.ColumnUuid salleId;

  late final _i2.ColumnDateTime debutAt;

  late final _i2.ColumnDateTime finAt;

  late final _i2.ColumnString format;

  late final _i2.ColumnString type;

  late final _i2.ColumnDouble prixBase;

  late final _i2.ColumnSerializable<List<String>> availableOptions;

  @override
  List<_i2.Column> get columns => [
    id,
    createdAt,
    filmId,
    salleId,
    debutAt,
    finAt,
    format,
    type,
    prixBase,
    availableOptions,
  ];
}

class SeanceInclude extends _i2.IncludeObject {
  SeanceInclude._();

  @override
  Map<String, _i2.Include?> get includes => {};

  @override
  _i2.Table<_i2.UuidValue> get table => Seance.t;
}

class SeanceIncludeList extends _i2.IncludeList {
  SeanceIncludeList._({
    _i2.WhereExpressionBuilder<SeanceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Seance.t);
  }

  @override
  Map<String, _i2.Include?> get includes => include?.includes ?? {};

  @override
  _i2.Table<_i2.UuidValue> get table => Seance.t;
}

class SeanceRepository {
  const SeanceRepository._();

  /// Returns a list of [Seance]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Seance>> find(
    _i2.Session session, {
    _i2.WhereExpressionBuilder<SeanceTable>? where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<SeanceTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<SeanceTable>? orderByList,
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Seance>(
      where: where?.call(Seance.t),
      orderBy: orderBy?.call(Seance.t),
      orderByList: orderByList?.call(Seance.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Seance] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Seance?> findFirstRow(
    _i2.Session session, {
    _i2.WhereExpressionBuilder<SeanceTable>? where,
    int? offset,
    _i2.OrderByBuilder<SeanceTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<SeanceTable>? orderByList,
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Seance>(
      where: where?.call(Seance.t),
      orderBy: orderBy?.call(Seance.t),
      orderByList: orderByList?.call(Seance.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Seance] by its [id] or null if no such row exists.
  Future<Seance?> findById(
    _i2.Session session,
    _i2.UuidValue id, {
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Seance>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Seance]s in the list and returns the inserted rows.
  ///
  /// The returned [Seance]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Seance>> insert(
    _i2.Session session,
    List<Seance> rows, {
    _i2.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Seance>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Seance] and returns the inserted row.
  ///
  /// The returned [Seance] will have its `id` field set.
  Future<Seance> insertRow(
    _i2.Session session,
    Seance row, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.insertRow<Seance>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Seance]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Seance>> update(
    _i2.Session session,
    List<Seance> rows, {
    _i2.ColumnSelections<SeanceTable>? columns,
    _i2.Transaction? transaction,
  }) async {
    return session.db.update<Seance>(
      rows,
      columns: columns?.call(Seance.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Seance]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Seance> updateRow(
    _i2.Session session,
    Seance row, {
    _i2.ColumnSelections<SeanceTable>? columns,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateRow<Seance>(
      row,
      columns: columns?.call(Seance.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Seance] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Seance?> updateById(
    _i2.Session session,
    _i2.UuidValue id, {
    required _i2.ColumnValueListBuilder<SeanceUpdateTable> columnValues,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateById<Seance>(
      id,
      columnValues: columnValues(Seance.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Seance]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Seance>> updateWhere(
    _i2.Session session, {
    required _i2.ColumnValueListBuilder<SeanceUpdateTable> columnValues,
    required _i2.WhereExpressionBuilder<SeanceTable> where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<SeanceTable>? orderBy,
    _i2.OrderByListBuilder<SeanceTable>? orderByList,
    bool orderDescending = false,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Seance>(
      columnValues: columnValues(Seance.t.updateTable),
      where: where(Seance.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Seance.t),
      orderByList: orderByList?.call(Seance.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Seance]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Seance>> delete(
    _i2.Session session,
    List<Seance> rows, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.delete<Seance>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Seance].
  Future<Seance> deleteRow(
    _i2.Session session,
    Seance row, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Seance>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Seance>> deleteWhere(
    _i2.Session session, {
    required _i2.WhereExpressionBuilder<SeanceTable> where,
    _i2.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Seance>(
      where: where(Seance.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i2.Session session, {
    _i2.WhereExpressionBuilder<SeanceTable>? where,
    int? limit,
    _i2.Transaction? transaction,
  }) async {
    return session.db.count<Seance>(
      where: where?.call(Seance.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Seance] rows matching the [where] expression.
  Future<void> lockRows(
    _i2.Session session, {
    required _i2.WhereExpressionBuilder<SeanceTable> where,
    required _i2.LockMode lockMode,
    required _i2.Transaction transaction,
    _i2.LockBehavior lockBehavior = _i2.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Seance>(
      where: where(Seance.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
