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

abstract class PhoneAuthCode
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = PhoneAuthCodeTable();

  static const db = PhoneAuthCodeRepository._();

  @override
  int? id;

  String phone;

  String code;

  DateTime createdAt;

  DateTime expiresAt;

  int attemptCount;

  DateTime? consumedAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static PhoneAuthCodeInclude include() {
    return PhoneAuthCodeInclude._();
  }

  static PhoneAuthCodeIncludeList includeList({
    _i1.WhereExpressionBuilder<PhoneAuthCodeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhoneAuthCodeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhoneAuthCodeTable>? orderByList,
    PhoneAuthCodeInclude? include,
  }) {
    return PhoneAuthCodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PhoneAuthCode.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PhoneAuthCode.t),
      include: include,
    );
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

class PhoneAuthCodeUpdateTable extends _i1.UpdateTable<PhoneAuthCodeTable> {
  PhoneAuthCodeUpdateTable(super.table);

  _i1.ColumnValue<String, String> phone(String value) => _i1.ColumnValue(
    table.phone,
    value,
  );

  _i1.ColumnValue<String, String> code(String value) => _i1.ColumnValue(
    table.code,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );

  _i1.ColumnValue<int, int> attemptCount(int value) => _i1.ColumnValue(
    table.attemptCount,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> consumedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.consumedAt,
        value,
      );
}

class PhoneAuthCodeTable extends _i1.Table<int?> {
  PhoneAuthCodeTable({super.tableRelation})
    : super(tableName: 'phone_auth_code') {
    updateTable = PhoneAuthCodeUpdateTable(this);
    phone = _i1.ColumnString(
      'phone',
      this,
    );
    code = _i1.ColumnString(
      'code',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
    attemptCount = _i1.ColumnInt(
      'attemptCount',
      this,
      hasDefault: true,
    );
    consumedAt = _i1.ColumnDateTime(
      'consumedAt',
      this,
    );
  }

  late final PhoneAuthCodeUpdateTable updateTable;

  late final _i1.ColumnString phone;

  late final _i1.ColumnString code;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnInt attemptCount;

  late final _i1.ColumnDateTime consumedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    phone,
    code,
    createdAt,
    expiresAt,
    attemptCount,
    consumedAt,
  ];
}

class PhoneAuthCodeInclude extends _i1.IncludeObject {
  PhoneAuthCodeInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PhoneAuthCode.t;
}

class PhoneAuthCodeIncludeList extends _i1.IncludeList {
  PhoneAuthCodeIncludeList._({
    _i1.WhereExpressionBuilder<PhoneAuthCodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PhoneAuthCode.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PhoneAuthCode.t;
}

class PhoneAuthCodeRepository {
  const PhoneAuthCodeRepository._();

  /// Returns a list of [PhoneAuthCode]s matching the given query parameters.
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
  Future<List<PhoneAuthCode>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PhoneAuthCodeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhoneAuthCodeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhoneAuthCodeTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PhoneAuthCode>(
      where: where?.call(PhoneAuthCode.t),
      orderBy: orderBy?.call(PhoneAuthCode.t),
      orderByList: orderByList?.call(PhoneAuthCode.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PhoneAuthCode] matching the given query parameters.
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
  Future<PhoneAuthCode?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PhoneAuthCodeTable>? where,
    int? offset,
    _i1.OrderByBuilder<PhoneAuthCodeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhoneAuthCodeTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PhoneAuthCode>(
      where: where?.call(PhoneAuthCode.t),
      orderBy: orderBy?.call(PhoneAuthCode.t),
      orderByList: orderByList?.call(PhoneAuthCode.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PhoneAuthCode] by its [id] or null if no such row exists.
  Future<PhoneAuthCode?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PhoneAuthCode>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PhoneAuthCode]s in the list and returns the inserted rows.
  ///
  /// The returned [PhoneAuthCode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PhoneAuthCode>> insert(
    _i1.DatabaseSession session,
    List<PhoneAuthCode> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PhoneAuthCode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PhoneAuthCode] and returns the inserted row.
  ///
  /// The returned [PhoneAuthCode] will have its `id` field set.
  Future<PhoneAuthCode> insertRow(
    _i1.DatabaseSession session,
    PhoneAuthCode row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PhoneAuthCode>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PhoneAuthCode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PhoneAuthCode>> update(
    _i1.DatabaseSession session,
    List<PhoneAuthCode> rows, {
    _i1.ColumnSelections<PhoneAuthCodeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PhoneAuthCode>(
      rows,
      columns: columns?.call(PhoneAuthCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PhoneAuthCode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PhoneAuthCode> updateRow(
    _i1.DatabaseSession session,
    PhoneAuthCode row, {
    _i1.ColumnSelections<PhoneAuthCodeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PhoneAuthCode>(
      row,
      columns: columns?.call(PhoneAuthCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PhoneAuthCode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PhoneAuthCode?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PhoneAuthCodeUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PhoneAuthCode>(
      id,
      columnValues: columnValues(PhoneAuthCode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PhoneAuthCode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PhoneAuthCode>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PhoneAuthCodeUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PhoneAuthCodeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhoneAuthCodeTable>? orderBy,
    _i1.OrderByListBuilder<PhoneAuthCodeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PhoneAuthCode>(
      columnValues: columnValues(PhoneAuthCode.t.updateTable),
      where: where(PhoneAuthCode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PhoneAuthCode.t),
      orderByList: orderByList?.call(PhoneAuthCode.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PhoneAuthCode]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PhoneAuthCode>> delete(
    _i1.DatabaseSession session,
    List<PhoneAuthCode> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PhoneAuthCode>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PhoneAuthCode].
  Future<PhoneAuthCode> deleteRow(
    _i1.DatabaseSession session,
    PhoneAuthCode row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PhoneAuthCode>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PhoneAuthCode>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PhoneAuthCodeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PhoneAuthCode>(
      where: where(PhoneAuthCode.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PhoneAuthCodeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PhoneAuthCode>(
      where: where?.call(PhoneAuthCode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PhoneAuthCode] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PhoneAuthCodeTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PhoneAuthCode>(
      where: where(PhoneAuthCode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
