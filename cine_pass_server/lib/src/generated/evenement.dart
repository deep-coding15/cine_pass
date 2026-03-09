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

/// Événement (concert, théâtre, etc.).
abstract class Evenement extends _i1.CinePassRow
    implements _i2.TableRow<_i2.UuidValue>, _i2.ProtocolSerialization {
  Evenement._({
    _i2.UuidValue? id,
    super.createdAt,
    required this.titre,
    required this.categorie,
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
  }) : id = id ?? const _i2.Uuid().v4obj();

  factory Evenement({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required String titre,
    required String categorie,
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
    );
  }

  static final t = EvenementTable();

  static const db = EvenementRepository._();

  @override
  _i2.UuidValue id;

  String titre;

  String categorie;

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

  @override
  _i2.Table<_i2.UuidValue> get table => t;

  /// Returns a shallow copy of this [Evenement]
  /// with some or all fields replaced by the given arguments.
  @override
  @_i2.useResult
  Evenement copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    String? titre,
    String? categorie,
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
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Evenement',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'titre': titre,
      'categorie': categorie,
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
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Evenement',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'titre': titre,
      'categorie': categorie,
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
    };
  }

  static EvenementInclude include() {
    return EvenementInclude._();
  }

  static EvenementIncludeList includeList({
    _i2.WhereExpressionBuilder<EvenementTable>? where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<EvenementTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<EvenementTable>? orderByList,
    EvenementInclude? include,
  }) {
    return EvenementIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Evenement.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Evenement.t),
      include: include,
    );
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
  }) : super._(
         id: id,
         createdAt: createdAt,
         titre: titre,
         categorie: categorie,
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
  }) {
    return Evenement(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      titre: titre ?? this.titre,
      categorie: categorie ?? this.categorie,
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
    );
  }
}

class EvenementUpdateTable extends _i2.UpdateTable<EvenementTable> {
  EvenementUpdateTable(super.table);

  _i2.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i2.ColumnValue(
        table.createdAt,
        value,
      );

  _i2.ColumnValue<String, String> titre(String value) => _i2.ColumnValue(
    table.titre,
    value,
  );

  _i2.ColumnValue<String, String> categorie(String value) => _i2.ColumnValue(
    table.categorie,
    value,
  );

  _i2.ColumnValue<String, String> description(String? value) => _i2.ColumnValue(
    table.description,
    value,
  );

  _i2.ColumnValue<String, String> lieu(String value) => _i2.ColumnValue(
    table.lieu,
    value,
  );

  _i2.ColumnValue<String, String> adresse(String? value) => _i2.ColumnValue(
    table.adresse,
    value,
  );

  _i2.ColumnValue<String, String> ville(String value) => _i2.ColumnValue(
    table.ville,
    value,
  );

  _i2.ColumnValue<DateTime, DateTime> eventDate(DateTime value) =>
      _i2.ColumnValue(
        table.eventDate,
        value,
      );

  _i2.ColumnValue<DateTime, DateTime> eventTime(DateTime value) =>
      _i2.ColumnValue(
        table.eventTime,
        value,
      );

  _i2.ColumnValue<int, int> placesTotal(int value) => _i2.ColumnValue(
    table.placesTotal,
    value,
  );

  _i2.ColumnValue<double, double> prixBase(double value) => _i2.ColumnValue(
    table.prixBase,
    value,
  );

  _i2.ColumnValue<int, int> posterColor(int? value) => _i2.ColumnValue(
    table.posterColor,
    value,
  );

  _i2.ColumnValue<String, String> posterUrl(String? value) => _i2.ColumnValue(
    table.posterUrl,
    value,
  );

  _i2.ColumnValue<List<String>, List<String>> availableOptions(
    List<String>? value,
  ) => _i2.ColumnValue(
    table.availableOptions,
    value,
  );
}

class EvenementTable extends _i2.Table<_i2.UuidValue> {
  EvenementTable({super.tableRelation})
    : super(tableName: 'cine_pass_evenement') {
    updateTable = EvenementUpdateTable(this);
    createdAt = _i2.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    titre = _i2.ColumnString(
      'titre',
      this,
    );
    categorie = _i2.ColumnString(
      'categorie',
      this,
    );
    description = _i2.ColumnString(
      'description',
      this,
    );
    lieu = _i2.ColumnString(
      'lieu',
      this,
    );
    adresse = _i2.ColumnString(
      'adresse',
      this,
    );
    ville = _i2.ColumnString(
      'ville',
      this,
    );
    eventDate = _i2.ColumnDateTime(
      'eventDate',
      this,
    );
    eventTime = _i2.ColumnDateTime(
      'eventTime',
      this,
    );
    placesTotal = _i2.ColumnInt(
      'placesTotal',
      this,
    );
    prixBase = _i2.ColumnDouble(
      'prixBase',
      this,
    );
    posterColor = _i2.ColumnInt(
      'posterColor',
      this,
    );
    posterUrl = _i2.ColumnString(
      'posterUrl',
      this,
    );
    availableOptions = _i2.ColumnSerializable<List<String>>(
      'availableOptions',
      this,
    );
  }

  late final EvenementUpdateTable updateTable;

  late final _i2.ColumnDateTime createdAt;

  late final _i2.ColumnString titre;

  late final _i2.ColumnString categorie;

  late final _i2.ColumnString description;

  late final _i2.ColumnString lieu;

  late final _i2.ColumnString adresse;

  late final _i2.ColumnString ville;

  late final _i2.ColumnDateTime eventDate;

  late final _i2.ColumnDateTime eventTime;

  late final _i2.ColumnInt placesTotal;

  late final _i2.ColumnDouble prixBase;

  late final _i2.ColumnInt posterColor;

  late final _i2.ColumnString posterUrl;

  late final _i2.ColumnSerializable<List<String>> availableOptions;

  @override
  List<_i2.Column> get columns => [
    id,
    createdAt,
    titre,
    categorie,
    description,
    lieu,
    adresse,
    ville,
    eventDate,
    eventTime,
    placesTotal,
    prixBase,
    posterColor,
    posterUrl,
    availableOptions,
  ];
}

class EvenementInclude extends _i2.IncludeObject {
  EvenementInclude._();

  @override
  Map<String, _i2.Include?> get includes => {};

  @override
  _i2.Table<_i2.UuidValue> get table => Evenement.t;
}

class EvenementIncludeList extends _i2.IncludeList {
  EvenementIncludeList._({
    _i2.WhereExpressionBuilder<EvenementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Evenement.t);
  }

  @override
  Map<String, _i2.Include?> get includes => include?.includes ?? {};

  @override
  _i2.Table<_i2.UuidValue> get table => Evenement.t;
}

class EvenementRepository {
  const EvenementRepository._();

  /// Returns a list of [Evenement]s matching the given query parameters.
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
  Future<List<Evenement>> find(
    _i2.Session session, {
    _i2.WhereExpressionBuilder<EvenementTable>? where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<EvenementTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<EvenementTable>? orderByList,
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Evenement>(
      where: where?.call(Evenement.t),
      orderBy: orderBy?.call(Evenement.t),
      orderByList: orderByList?.call(Evenement.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Evenement] matching the given query parameters.
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
  Future<Evenement?> findFirstRow(
    _i2.Session session, {
    _i2.WhereExpressionBuilder<EvenementTable>? where,
    int? offset,
    _i2.OrderByBuilder<EvenementTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<EvenementTable>? orderByList,
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Evenement>(
      where: where?.call(Evenement.t),
      orderBy: orderBy?.call(Evenement.t),
      orderByList: orderByList?.call(Evenement.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Evenement] by its [id] or null if no such row exists.
  Future<Evenement?> findById(
    _i2.Session session,
    _i2.UuidValue id, {
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Evenement>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Evenement]s in the list and returns the inserted rows.
  ///
  /// The returned [Evenement]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Evenement>> insert(
    _i2.Session session,
    List<Evenement> rows, {
    _i2.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Evenement>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Evenement] and returns the inserted row.
  ///
  /// The returned [Evenement] will have its `id` field set.
  Future<Evenement> insertRow(
    _i2.Session session,
    Evenement row, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.insertRow<Evenement>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Evenement]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Evenement>> update(
    _i2.Session session,
    List<Evenement> rows, {
    _i2.ColumnSelections<EvenementTable>? columns,
    _i2.Transaction? transaction,
  }) async {
    return session.db.update<Evenement>(
      rows,
      columns: columns?.call(Evenement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Evenement]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Evenement> updateRow(
    _i2.Session session,
    Evenement row, {
    _i2.ColumnSelections<EvenementTable>? columns,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateRow<Evenement>(
      row,
      columns: columns?.call(Evenement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Evenement] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Evenement?> updateById(
    _i2.Session session,
    _i2.UuidValue id, {
    required _i2.ColumnValueListBuilder<EvenementUpdateTable> columnValues,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateById<Evenement>(
      id,
      columnValues: columnValues(Evenement.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Evenement]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Evenement>> updateWhere(
    _i2.Session session, {
    required _i2.ColumnValueListBuilder<EvenementUpdateTable> columnValues,
    required _i2.WhereExpressionBuilder<EvenementTable> where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<EvenementTable>? orderBy,
    _i2.OrderByListBuilder<EvenementTable>? orderByList,
    bool orderDescending = false,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Evenement>(
      columnValues: columnValues(Evenement.t.updateTable),
      where: where(Evenement.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Evenement.t),
      orderByList: orderByList?.call(Evenement.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Evenement]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Evenement>> delete(
    _i2.Session session,
    List<Evenement> rows, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.delete<Evenement>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Evenement].
  Future<Evenement> deleteRow(
    _i2.Session session,
    Evenement row, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Evenement>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Evenement>> deleteWhere(
    _i2.Session session, {
    required _i2.WhereExpressionBuilder<EvenementTable> where,
    _i2.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Evenement>(
      where: where(Evenement.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i2.Session session, {
    _i2.WhereExpressionBuilder<EvenementTable>? where,
    int? limit,
    _i2.Transaction? transaction,
  }) async {
    return session.db.count<Evenement>(
      where: where?.call(Evenement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Evenement] rows matching the [where] expression.
  Future<void> lockRows(
    _i2.Session session, {
    required _i2.WhereExpressionBuilder<EvenementTable> where,
    required _i2.LockMode lockMode,
    required _i2.Transaction transaction,
    _i2.LockBehavior lockBehavior = _i2.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Evenement>(
      where: where(Evenement.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
