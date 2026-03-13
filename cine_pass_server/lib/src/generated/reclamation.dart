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

/// Réclamation client (lié à un événement / structure).
abstract class Reclamation extends _i1.CinePassRow
    implements _i2.TableRow<_i2.UuidValue>, _i2.ProtocolSerialization {
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

  static final t = ReclamationTable();

  static const db = ReclamationRepository._();

  @override
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

  @override
  _i2.Table<_i2.UuidValue> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static ReclamationInclude include() {
    return ReclamationInclude._();
  }

  static ReclamationIncludeList includeList({
    _i2.WhereExpressionBuilder<ReclamationTable>? where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<ReclamationTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<ReclamationTable>? orderByList,
    ReclamationInclude? include,
  }) {
    return ReclamationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Reclamation.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Reclamation.t),
      include: include,
    );
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

class ReclamationUpdateTable extends _i2.UpdateTable<ReclamationTable> {
  ReclamationUpdateTable(super.table);

  _i2.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i2.ColumnValue(
        table.createdAt,
        value,
      );

  _i2.ColumnValue<int, int> userId(int? value) => _i2.ColumnValue(
    table.userId,
    value,
  );

  _i2.ColumnValue<_i2.UuidValue, _i2.UuidValue> eventId(_i2.UuidValue? value) =>
      _i2.ColumnValue(
        table.eventId,
        value,
      );

  _i2.ColumnValue<_i2.UuidValue, _i2.UuidValue> structureId(
    _i2.UuidValue? value,
  ) => _i2.ColumnValue(
    table.structureId,
    value,
  );

  _i2.ColumnValue<String, String> sujet(String value) => _i2.ColumnValue(
    table.sujet,
    value,
  );

  _i2.ColumnValue<String, String> message(String value) => _i2.ColumnValue(
    table.message,
    value,
  );

  _i2.ColumnValue<String, String> statut(String value) => _i2.ColumnValue(
    table.statut,
    value,
  );

  _i2.ColumnValue<String, String> lastResponseFrom(String? value) =>
      _i2.ColumnValue(
        table.lastResponseFrom,
        value,
      );

  _i2.ColumnValue<String, String> lastResponse(String? value) =>
      _i2.ColumnValue(
        table.lastResponse,
        value,
      );

  _i2.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i2.ColumnValue(
        table.updatedAt,
        value,
      );
}

class ReclamationTable extends _i2.Table<_i2.UuidValue> {
  ReclamationTable({super.tableRelation})
    : super(tableName: 'cine_pass_reclamation') {
    updateTable = ReclamationUpdateTable(this);
    createdAt = _i2.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    userId = _i2.ColumnInt(
      'userId',
      this,
    );
    eventId = _i2.ColumnUuid(
      'eventId',
      this,
    );
    structureId = _i2.ColumnUuid(
      'structureId',
      this,
    );
    sujet = _i2.ColumnString(
      'sujet',
      this,
    );
    message = _i2.ColumnString(
      'message',
      this,
    );
    statut = _i2.ColumnString(
      'statut',
      this,
      hasDefault: true,
    );
    lastResponseFrom = _i2.ColumnString(
      'lastResponseFrom',
      this,
    );
    lastResponse = _i2.ColumnString(
      'lastResponse',
      this,
    );
    updatedAt = _i2.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final ReclamationUpdateTable updateTable;

  late final _i2.ColumnDateTime createdAt;

  late final _i2.ColumnInt userId;

  late final _i2.ColumnUuid eventId;

  late final _i2.ColumnUuid structureId;

  late final _i2.ColumnString sujet;

  late final _i2.ColumnString message;

  late final _i2.ColumnString statut;

  late final _i2.ColumnString lastResponseFrom;

  late final _i2.ColumnString lastResponse;

  late final _i2.ColumnDateTime updatedAt;

  @override
  List<_i2.Column> get columns => [
    id,
    createdAt,
    userId,
    eventId,
    structureId,
    sujet,
    message,
    statut,
    lastResponseFrom,
    lastResponse,
    updatedAt,
  ];
}

class ReclamationInclude extends _i2.IncludeObject {
  ReclamationInclude._();

  @override
  Map<String, _i2.Include?> get includes => {};

  @override
  _i2.Table<_i2.UuidValue> get table => Reclamation.t;
}

class ReclamationIncludeList extends _i2.IncludeList {
  ReclamationIncludeList._({
    _i2.WhereExpressionBuilder<ReclamationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Reclamation.t);
  }

  @override
  Map<String, _i2.Include?> get includes => include?.includes ?? {};

  @override
  _i2.Table<_i2.UuidValue> get table => Reclamation.t;
}

class ReclamationRepository {
  const ReclamationRepository._();

  /// Returns a list of [Reclamation]s matching the given query parameters.
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
  Future<List<Reclamation>> find(
    _i2.Session session, {
    _i2.WhereExpressionBuilder<ReclamationTable>? where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<ReclamationTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<ReclamationTable>? orderByList,
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Reclamation>(
      where: where?.call(Reclamation.t),
      orderBy: orderBy?.call(Reclamation.t),
      orderByList: orderByList?.call(Reclamation.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Reclamation] matching the given query parameters.
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
  Future<Reclamation?> findFirstRow(
    _i2.Session session, {
    _i2.WhereExpressionBuilder<ReclamationTable>? where,
    int? offset,
    _i2.OrderByBuilder<ReclamationTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<ReclamationTable>? orderByList,
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Reclamation>(
      where: where?.call(Reclamation.t),
      orderBy: orderBy?.call(Reclamation.t),
      orderByList: orderByList?.call(Reclamation.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Reclamation] by its [id] or null if no such row exists.
  Future<Reclamation?> findById(
    _i2.Session session,
    _i2.UuidValue id, {
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Reclamation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Reclamation]s in the list and returns the inserted rows.
  ///
  /// The returned [Reclamation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Reclamation>> insert(
    _i2.Session session,
    List<Reclamation> rows, {
    _i2.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Reclamation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Reclamation] and returns the inserted row.
  ///
  /// The returned [Reclamation] will have its `id` field set.
  Future<Reclamation> insertRow(
    _i2.Session session,
    Reclamation row, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.insertRow<Reclamation>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Reclamation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Reclamation>> update(
    _i2.Session session,
    List<Reclamation> rows, {
    _i2.ColumnSelections<ReclamationTable>? columns,
    _i2.Transaction? transaction,
  }) async {
    return session.db.update<Reclamation>(
      rows,
      columns: columns?.call(Reclamation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Reclamation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Reclamation> updateRow(
    _i2.Session session,
    Reclamation row, {
    _i2.ColumnSelections<ReclamationTable>? columns,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateRow<Reclamation>(
      row,
      columns: columns?.call(Reclamation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Reclamation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Reclamation?> updateById(
    _i2.Session session,
    _i2.UuidValue id, {
    required _i2.ColumnValueListBuilder<ReclamationUpdateTable> columnValues,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateById<Reclamation>(
      id,
      columnValues: columnValues(Reclamation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Reclamation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Reclamation>> updateWhere(
    _i2.Session session, {
    required _i2.ColumnValueListBuilder<ReclamationUpdateTable> columnValues,
    required _i2.WhereExpressionBuilder<ReclamationTable> where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<ReclamationTable>? orderBy,
    _i2.OrderByListBuilder<ReclamationTable>? orderByList,
    bool orderDescending = false,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Reclamation>(
      columnValues: columnValues(Reclamation.t.updateTable),
      where: where(Reclamation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Reclamation.t),
      orderByList: orderByList?.call(Reclamation.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Reclamation]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Reclamation>> delete(
    _i2.Session session,
    List<Reclamation> rows, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.delete<Reclamation>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Reclamation].
  Future<Reclamation> deleteRow(
    _i2.Session session,
    Reclamation row, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Reclamation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Reclamation>> deleteWhere(
    _i2.Session session, {
    required _i2.WhereExpressionBuilder<ReclamationTable> where,
    _i2.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Reclamation>(
      where: where(Reclamation.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i2.Session session, {
    _i2.WhereExpressionBuilder<ReclamationTable>? where,
    int? limit,
    _i2.Transaction? transaction,
  }) async {
    return session.db.count<Reclamation>(
      where: where?.call(Reclamation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Reclamation] rows matching the [where] expression.
  Future<void> lockRows(
    _i2.Session session, {
    required _i2.WhereExpressionBuilder<ReclamationTable> where,
    required _i2.LockMode lockMode,
    required _i2.Transaction transaction,
    _i2.LockBehavior lockBehavior = _i2.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Reclamation>(
      where: where(Reclamation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
