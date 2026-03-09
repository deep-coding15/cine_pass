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

/// Siège dans une salle (plan de salle).
abstract class Siege
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  Siege._({
    _i1.UuidValue? id,
    required this.salleId,
    required this.rangee,
    required this.numero,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory Siege({
    _i1.UuidValue? id,
    required _i1.UuidValue salleId,
    required String rangee,
    required int numero,
  }) = _SiegeImpl;

  factory Siege.fromJson(Map<String, dynamic> jsonSerialization) {
    return Siege(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      salleId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['salleId'],
      ),
      rangee: jsonSerialization['rangee'] as String,
      numero: jsonSerialization['numero'] as int,
    );
  }

  static final t = SiegeTable();

  static const db = SiegeRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue salleId;

  String rangee;

  int numero;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [Siege]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Siege copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? salleId,
    String? rangee,
    int? numero,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Siege',
      'id': id.toJson(),
      'salleId': salleId.toJson(),
      'rangee': rangee,
      'numero': numero,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Siege',
      'id': id.toJson(),
      'salleId': salleId.toJson(),
      'rangee': rangee,
      'numero': numero,
    };
  }

  static SiegeInclude include() {
    return SiegeInclude._();
  }

  static SiegeIncludeList includeList({
    _i1.WhereExpressionBuilder<SiegeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SiegeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SiegeTable>? orderByList,
    SiegeInclude? include,
  }) {
    return SiegeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Siege.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Siege.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SiegeImpl extends Siege {
  _SiegeImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue salleId,
    required String rangee,
    required int numero,
  }) : super._(
         id: id,
         salleId: salleId,
         rangee: rangee,
         numero: numero,
       );

  /// Returns a shallow copy of this [Siege]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Siege copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? salleId,
    String? rangee,
    int? numero,
  }) {
    return Siege(
      id: id ?? this.id,
      salleId: salleId ?? this.salleId,
      rangee: rangee ?? this.rangee,
      numero: numero ?? this.numero,
    );
  }
}

class SiegeUpdateTable extends _i1.UpdateTable<SiegeTable> {
  SiegeUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> salleId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.salleId,
        value,
      );

  _i1.ColumnValue<String, String> rangee(String value) => _i1.ColumnValue(
    table.rangee,
    value,
  );

  _i1.ColumnValue<int, int> numero(int value) => _i1.ColumnValue(
    table.numero,
    value,
  );
}

class SiegeTable extends _i1.Table<_i1.UuidValue> {
  SiegeTable({super.tableRelation}) : super(tableName: 'cine_pass_siege') {
    updateTable = SiegeUpdateTable(this);
    salleId = _i1.ColumnUuid(
      'salleId',
      this,
    );
    rangee = _i1.ColumnString(
      'rangee',
      this,
    );
    numero = _i1.ColumnInt(
      'numero',
      this,
    );
  }

  late final SiegeUpdateTable updateTable;

  late final _i1.ColumnUuid salleId;

  late final _i1.ColumnString rangee;

  late final _i1.ColumnInt numero;

  @override
  List<_i1.Column> get columns => [
    id,
    salleId,
    rangee,
    numero,
  ];
}

class SiegeInclude extends _i1.IncludeObject {
  SiegeInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => Siege.t;
}

class SiegeIncludeList extends _i1.IncludeList {
  SiegeIncludeList._({
    _i1.WhereExpressionBuilder<SiegeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Siege.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => Siege.t;
}

class SiegeRepository {
  const SiegeRepository._();

  /// Returns a list of [Siege]s matching the given query parameters.
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
  Future<List<Siege>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SiegeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SiegeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SiegeTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Siege>(
      where: where?.call(Siege.t),
      orderBy: orderBy?.call(Siege.t),
      orderByList: orderByList?.call(Siege.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Siege] matching the given query parameters.
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
  Future<Siege?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SiegeTable>? where,
    int? offset,
    _i1.OrderByBuilder<SiegeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SiegeTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Siege>(
      where: where?.call(Siege.t),
      orderBy: orderBy?.call(Siege.t),
      orderByList: orderByList?.call(Siege.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Siege] by its [id] or null if no such row exists.
  Future<Siege?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Siege>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Siege]s in the list and returns the inserted rows.
  ///
  /// The returned [Siege]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Siege>> insert(
    _i1.Session session,
    List<Siege> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Siege>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Siege] and returns the inserted row.
  ///
  /// The returned [Siege] will have its `id` field set.
  Future<Siege> insertRow(
    _i1.Session session,
    Siege row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Siege>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Siege]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Siege>> update(
    _i1.Session session,
    List<Siege> rows, {
    _i1.ColumnSelections<SiegeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Siege>(
      rows,
      columns: columns?.call(Siege.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Siege]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Siege> updateRow(
    _i1.Session session,
    Siege row, {
    _i1.ColumnSelections<SiegeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Siege>(
      row,
      columns: columns?.call(Siege.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Siege] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Siege?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SiegeUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Siege>(
      id,
      columnValues: columnValues(Siege.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Siege]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Siege>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SiegeUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SiegeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SiegeTable>? orderBy,
    _i1.OrderByListBuilder<SiegeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Siege>(
      columnValues: columnValues(Siege.t.updateTable),
      where: where(Siege.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Siege.t),
      orderByList: orderByList?.call(Siege.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Siege]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Siege>> delete(
    _i1.Session session,
    List<Siege> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Siege>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Siege].
  Future<Siege> deleteRow(
    _i1.Session session,
    Siege row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Siege>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Siege>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SiegeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Siege>(
      where: where(Siege.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SiegeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Siege>(
      where: where?.call(Siege.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Siege] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SiegeTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Siege>(
      where: where(Siege.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
