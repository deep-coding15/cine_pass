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

/// Structure (cinéma, salle, organisateur) — table gérée par le schéma SQL.
abstract class Structure
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  Structure._({
    _i1.UuidValue? id,
    required this.type,
    required this.name,
    required this.city,
    this.address,
    this.website,
    this.phone,
    this.cinemaId,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory Structure({
    _i1.UuidValue? id,
    required String type,
    required String name,
    required String city,
    String? address,
    String? website,
    String? phone,
    _i1.UuidValue? cinemaId,
  }) = _StructureImpl;

  factory Structure.fromJson(Map<String, dynamic> jsonSerialization) {
    return Structure(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      type: jsonSerialization['type'] as String,
      name: jsonSerialization['name'] as String,
      city: jsonSerialization['city'] as String,
      address: jsonSerialization['address'] as String?,
      website: jsonSerialization['website'] as String?,
      phone: jsonSerialization['phone'] as String?,
      cinemaId: jsonSerialization['cinemaId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['cinemaId']),
    );
  }

  static final t = StructureTable();

  static const db = StructureRepository._();

  @override
  _i1.UuidValue id;

  String type;

  String name;

  String city;

  String? address;

  String? website;

  String? phone;

  _i1.UuidValue? cinemaId;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [Structure]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Structure copyWith({
    _i1.UuidValue? id,
    String? type,
    String? name,
    String? city,
    String? address,
    String? website,
    String? phone,
    _i1.UuidValue? cinemaId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Structure',
      'id': id.toJson(),
      'type': type,
      'name': name,
      'city': city,
      if (address != null) 'address': address,
      if (website != null) 'website': website,
      if (phone != null) 'phone': phone,
      if (cinemaId != null) 'cinemaId': cinemaId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Structure',
      'id': id.toJson(),
      'type': type,
      'name': name,
      'city': city,
      if (address != null) 'address': address,
      if (website != null) 'website': website,
      if (phone != null) 'phone': phone,
      if (cinemaId != null) 'cinemaId': cinemaId?.toJson(),
    };
  }

  static StructureInclude include() {
    return StructureInclude._();
  }

  static StructureIncludeList includeList({
    _i1.WhereExpressionBuilder<StructureTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StructureTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StructureTable>? orderByList,
    StructureInclude? include,
  }) {
    return StructureIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Structure.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Structure.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StructureImpl extends Structure {
  _StructureImpl({
    _i1.UuidValue? id,
    required String type,
    required String name,
    required String city,
    String? address,
    String? website,
    String? phone,
    _i1.UuidValue? cinemaId,
  }) : super._(
         id: id,
         type: type,
         name: name,
         city: city,
         address: address,
         website: website,
         phone: phone,
         cinemaId: cinemaId,
       );

  /// Returns a shallow copy of this [Structure]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Structure copyWith({
    _i1.UuidValue? id,
    String? type,
    String? name,
    String? city,
    Object? address = _Undefined,
    Object? website = _Undefined,
    Object? phone = _Undefined,
    Object? cinemaId = _Undefined,
  }) {
    return Structure(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address is String? ? address : this.address,
      website: website is String? ? website : this.website,
      phone: phone is String? ? phone : this.phone,
      cinemaId: cinemaId is _i1.UuidValue? ? cinemaId : this.cinemaId,
    );
  }
}

class StructureUpdateTable extends _i1.UpdateTable<StructureTable> {
  StructureUpdateTable(super.table);

  _i1.ColumnValue<String, String> type(String value) => _i1.ColumnValue(
    table.type,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> city(String value) => _i1.ColumnValue(
    table.city,
    value,
  );

  _i1.ColumnValue<String, String> address(String? value) => _i1.ColumnValue(
    table.address,
    value,
  );

  _i1.ColumnValue<String, String> website(String? value) => _i1.ColumnValue(
    table.website,
    value,
  );

  _i1.ColumnValue<String, String> phone(String? value) => _i1.ColumnValue(
    table.phone,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> cinemaId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.cinemaId,
    value,
  );
}

class StructureTable extends _i1.Table<_i1.UuidValue> {
  StructureTable({super.tableRelation})
    : super(tableName: 'cine_pass_structure') {
    updateTable = StructureUpdateTable(this);
    type = _i1.ColumnString(
      'type',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    city = _i1.ColumnString(
      'city',
      this,
    );
    address = _i1.ColumnString(
      'address',
      this,
    );
    website = _i1.ColumnString(
      'website',
      this,
    );
    phone = _i1.ColumnString(
      'phone',
      this,
    );
    cinemaId = _i1.ColumnUuid(
      'cinemaId',
      this,
    );
  }

  late final StructureUpdateTable updateTable;

  late final _i1.ColumnString type;

  late final _i1.ColumnString name;

  late final _i1.ColumnString city;

  late final _i1.ColumnString address;

  late final _i1.ColumnString website;

  late final _i1.ColumnString phone;

  late final _i1.ColumnUuid cinemaId;

  @override
  List<_i1.Column> get columns => [
    id,
    type,
    name,
    city,
    address,
    website,
    phone,
    cinemaId,
  ];
}

class StructureInclude extends _i1.IncludeObject {
  StructureInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => Structure.t;
}

class StructureIncludeList extends _i1.IncludeList {
  StructureIncludeList._({
    _i1.WhereExpressionBuilder<StructureTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Structure.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => Structure.t;
}

class StructureRepository {
  const StructureRepository._();

  /// Returns a list of [Structure]s matching the given query parameters.
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
  Future<List<Structure>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<StructureTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StructureTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StructureTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Structure>(
      where: where?.call(Structure.t),
      orderBy: orderBy?.call(Structure.t),
      orderByList: orderByList?.call(Structure.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Structure] matching the given query parameters.
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
  Future<Structure?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<StructureTable>? where,
    int? offset,
    _i1.OrderByBuilder<StructureTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StructureTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Structure>(
      where: where?.call(Structure.t),
      orderBy: orderBy?.call(Structure.t),
      orderByList: orderByList?.call(Structure.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Structure] by its [id] or null if no such row exists.
  Future<Structure?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Structure>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Structure]s in the list and returns the inserted rows.
  ///
  /// The returned [Structure]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Structure>> insert(
    _i1.Session session,
    List<Structure> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Structure>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Structure] and returns the inserted row.
  ///
  /// The returned [Structure] will have its `id` field set.
  Future<Structure> insertRow(
    _i1.Session session,
    Structure row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Structure>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Structure]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Structure>> update(
    _i1.Session session,
    List<Structure> rows, {
    _i1.ColumnSelections<StructureTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Structure>(
      rows,
      columns: columns?.call(Structure.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Structure]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Structure> updateRow(
    _i1.Session session,
    Structure row, {
    _i1.ColumnSelections<StructureTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Structure>(
      row,
      columns: columns?.call(Structure.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Structure] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Structure?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<StructureUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Structure>(
      id,
      columnValues: columnValues(Structure.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Structure]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Structure>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<StructureUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<StructureTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StructureTable>? orderBy,
    _i1.OrderByListBuilder<StructureTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Structure>(
      columnValues: columnValues(Structure.t.updateTable),
      where: where(Structure.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Structure.t),
      orderByList: orderByList?.call(Structure.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Structure]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Structure>> delete(
    _i1.Session session,
    List<Structure> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Structure>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Structure].
  Future<Structure> deleteRow(
    _i1.Session session,
    Structure row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Structure>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Structure>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<StructureTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Structure>(
      where: where(Structure.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<StructureTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Structure>(
      where: where?.call(Structure.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Structure] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<StructureTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Structure>(
      where: where(Structure.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
