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

/// Film (affichage programmation).
abstract class Film extends _i1.CinePassRow
    implements _i2.TableRow<_i2.UuidValue>, _i2.ProtocolSerialization {
  Film._({
    _i2.UuidValue? id,
    super.createdAt,
    required this.titre,
    required this.genre,
    required this.dureeMinutes,
    this.synopsis,
    this.directeur,
    this.casting,
    this.posterColor,
    this.posterUrl,
    this.dateSortie,
    this.dateFin,
    this.audience,
    DateTime? updatedAt,
  }) : id = id ?? const _i2.Uuid().v4obj(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Film({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required String titre,
    required String genre,
    required int dureeMinutes,
    String? synopsis,
    String? directeur,
    String? casting,
    int? posterColor,
    String? posterUrl,
    DateTime? dateSortie,
    DateTime? dateFin,
    String? audience,
    DateTime? updatedAt,
  }) = _FilmImpl;

  factory Film.fromJson(Map<String, dynamic> jsonSerialization) {
    return Film(
      id: jsonSerialization['id'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      titre: jsonSerialization['titre'] as String,
      genre: jsonSerialization['genre'] as String,
      dureeMinutes: jsonSerialization['dureeMinutes'] as int,
      synopsis: jsonSerialization['synopsis'] as String?,
      directeur: jsonSerialization['directeur'] as String?,
      casting: jsonSerialization['casting'] as String?,
      posterColor: jsonSerialization['posterColor'] as int?,
      posterUrl: jsonSerialization['posterUrl'] as String?,
      dateSortie: jsonSerialization['dateSortie'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['dateSortie']),
      dateFin: jsonSerialization['dateFin'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['dateFin']),
      audience: jsonSerialization['audience'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = FilmTable();

  static const db = FilmRepository._();

  @override
  _i2.UuidValue id;

  String titre;

  String genre;

  int dureeMinutes;

  String? synopsis;

  String? directeur;

  String? casting;

  int? posterColor;

  String? posterUrl;

  DateTime? dateSortie;

  DateTime? dateFin;

  String? audience;

  DateTime updatedAt;

  @override
  _i2.Table<_i2.UuidValue> get table => t;

  /// Returns a shallow copy of this [Film]
  /// with some or all fields replaced by the given arguments.
  @override
  @_i2.useResult
  Film copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    String? titre,
    String? genre,
    int? dureeMinutes,
    String? synopsis,
    String? directeur,
    String? casting,
    int? posterColor,
    String? posterUrl,
    DateTime? dateSortie,
    DateTime? dateFin,
    String? audience,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Film',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'titre': titre,
      'genre': genre,
      'dureeMinutes': dureeMinutes,
      if (synopsis != null) 'synopsis': synopsis,
      if (directeur != null) 'directeur': directeur,
      if (casting != null) 'casting': casting,
      if (posterColor != null) 'posterColor': posterColor,
      if (posterUrl != null) 'posterUrl': posterUrl,
      if (dateSortie != null) 'dateSortie': dateSortie?.toJson(),
      if (dateFin != null) 'dateFin': dateFin?.toJson(),
      if (audience != null) 'audience': audience,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Film',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'titre': titre,
      'genre': genre,
      'dureeMinutes': dureeMinutes,
      if (synopsis != null) 'synopsis': synopsis,
      if (directeur != null) 'directeur': directeur,
      if (casting != null) 'casting': casting,
      if (posterColor != null) 'posterColor': posterColor,
      if (posterUrl != null) 'posterUrl': posterUrl,
      if (dateSortie != null) 'dateSortie': dateSortie?.toJson(),
      if (dateFin != null) 'dateFin': dateFin?.toJson(),
      if (audience != null) 'audience': audience,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static FilmInclude include() {
    return FilmInclude._();
  }

  static FilmIncludeList includeList({
    _i2.WhereExpressionBuilder<FilmTable>? where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<FilmTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<FilmTable>? orderByList,
    FilmInclude? include,
  }) {
    return FilmIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Film.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Film.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i2.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FilmImpl extends Film {
  _FilmImpl({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required String titre,
    required String genre,
    required int dureeMinutes,
    String? synopsis,
    String? directeur,
    String? casting,
    int? posterColor,
    String? posterUrl,
    DateTime? dateSortie,
    DateTime? dateFin,
    String? audience,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         createdAt: createdAt,
         titre: titre,
         genre: genre,
         dureeMinutes: dureeMinutes,
         synopsis: synopsis,
         directeur: directeur,
         casting: casting,
         posterColor: posterColor,
         posterUrl: posterUrl,
         dateSortie: dateSortie,
         dateFin: dateFin,
         audience: audience,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Film]
  /// with some or all fields replaced by the given arguments.
  @_i2.useResult
  @override
  Film copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    String? titre,
    String? genre,
    int? dureeMinutes,
    Object? synopsis = _Undefined,
    Object? directeur = _Undefined,
    Object? casting = _Undefined,
    Object? posterColor = _Undefined,
    Object? posterUrl = _Undefined,
    Object? dateSortie = _Undefined,
    Object? dateFin = _Undefined,
    Object? audience = _Undefined,
    DateTime? updatedAt,
  }) {
    return Film(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      titre: titre ?? this.titre,
      genre: genre ?? this.genre,
      dureeMinutes: dureeMinutes ?? this.dureeMinutes,
      synopsis: synopsis is String? ? synopsis : this.synopsis,
      directeur: directeur is String? ? directeur : this.directeur,
      casting: casting is String? ? casting : this.casting,
      posterColor: posterColor is int? ? posterColor : this.posterColor,
      posterUrl: posterUrl is String? ? posterUrl : this.posterUrl,
      dateSortie: dateSortie is DateTime? ? dateSortie : this.dateSortie,
      dateFin: dateFin is DateTime? ? dateFin : this.dateFin,
      audience: audience is String? ? audience : this.audience,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FilmUpdateTable extends _i2.UpdateTable<FilmTable> {
  FilmUpdateTable(super.table);

  _i2.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i2.ColumnValue(
        table.createdAt,
        value,
      );

  _i2.ColumnValue<String, String> titre(String value) => _i2.ColumnValue(
    table.titre,
    value,
  );

  _i2.ColumnValue<String, String> genre(String value) => _i2.ColumnValue(
    table.genre,
    value,
  );

  _i2.ColumnValue<int, int> dureeMinutes(int value) => _i2.ColumnValue(
    table.dureeMinutes,
    value,
  );

  _i2.ColumnValue<String, String> synopsis(String? value) => _i2.ColumnValue(
    table.synopsis,
    value,
  );

  _i2.ColumnValue<String, String> directeur(String? value) => _i2.ColumnValue(
    table.directeur,
    value,
  );

  _i2.ColumnValue<String, String> casting(String? value) => _i2.ColumnValue(
    table.casting,
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

  _i2.ColumnValue<DateTime, DateTime> dateSortie(DateTime? value) =>
      _i2.ColumnValue(
        table.dateSortie,
        value,
      );

  _i2.ColumnValue<DateTime, DateTime> dateFin(DateTime? value) =>
      _i2.ColumnValue(
        table.dateFin,
        value,
      );

  _i2.ColumnValue<String, String> audience(String? value) => _i2.ColumnValue(
    table.audience,
    value,
  );

  _i2.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i2.ColumnValue(
        table.updatedAt,
        value,
      );
}

class FilmTable extends _i2.Table<_i2.UuidValue> {
  FilmTable({super.tableRelation}) : super(tableName: 'cine_pass_film') {
    updateTable = FilmUpdateTable(this);
    createdAt = _i2.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    titre = _i2.ColumnString(
      'titre',
      this,
    );
    genre = _i2.ColumnString(
      'genre',
      this,
    );
    dureeMinutes = _i2.ColumnInt(
      'dureeMinutes',
      this,
    );
    synopsis = _i2.ColumnString(
      'synopsis',
      this,
    );
    directeur = _i2.ColumnString(
      'directeur',
      this,
    );
    casting = _i2.ColumnString(
      'casting',
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
    dateSortie = _i2.ColumnDateTime(
      'dateSortie',
      this,
    );
    dateFin = _i2.ColumnDateTime(
      'dateFin',
      this,
    );
    audience = _i2.ColumnString(
      'audience',
      this,
    );
    updatedAt = _i2.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final FilmUpdateTable updateTable;

  late final _i2.ColumnDateTime createdAt;

  late final _i2.ColumnString titre;

  late final _i2.ColumnString genre;

  late final _i2.ColumnInt dureeMinutes;

  late final _i2.ColumnString synopsis;

  late final _i2.ColumnString directeur;

  late final _i2.ColumnString casting;

  late final _i2.ColumnInt posterColor;

  late final _i2.ColumnString posterUrl;

  late final _i2.ColumnDateTime dateSortie;

  late final _i2.ColumnDateTime dateFin;

  late final _i2.ColumnString audience;

  late final _i2.ColumnDateTime updatedAt;

  @override
  List<_i2.Column> get columns => [
    id,
    createdAt,
    titre,
    genre,
    dureeMinutes,
    synopsis,
    directeur,
    casting,
    posterColor,
    posterUrl,
    dateSortie,
    dateFin,
    audience,
    updatedAt,
  ];
}

class FilmInclude extends _i2.IncludeObject {
  FilmInclude._();

  @override
  Map<String, _i2.Include?> get includes => {};

  @override
  _i2.Table<_i2.UuidValue> get table => Film.t;
}

class FilmIncludeList extends _i2.IncludeList {
  FilmIncludeList._({
    _i2.WhereExpressionBuilder<FilmTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Film.t);
  }

  @override
  Map<String, _i2.Include?> get includes => include?.includes ?? {};

  @override
  _i2.Table<_i2.UuidValue> get table => Film.t;
}

class FilmRepository {
  const FilmRepository._();

  /// Returns a list of [Film]s matching the given query parameters.
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
  Future<List<Film>> find(
    _i2.DatabaseSession session, {
    _i2.WhereExpressionBuilder<FilmTable>? where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<FilmTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<FilmTable>? orderByList,
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Film>(
      where: where?.call(Film.t),
      orderBy: orderBy?.call(Film.t),
      orderByList: orderByList?.call(Film.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Film] matching the given query parameters.
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
  Future<Film?> findFirstRow(
    _i2.DatabaseSession session, {
    _i2.WhereExpressionBuilder<FilmTable>? where,
    int? offset,
    _i2.OrderByBuilder<FilmTable>? orderBy,
    bool orderDescending = false,
    _i2.OrderByListBuilder<FilmTable>? orderByList,
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Film>(
      where: where?.call(Film.t),
      orderBy: orderBy?.call(Film.t),
      orderByList: orderByList?.call(Film.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Film] by its [id] or null if no such row exists.
  Future<Film?> findById(
    _i2.DatabaseSession session,
    _i2.UuidValue id, {
    _i2.Transaction? transaction,
    _i2.LockMode? lockMode,
    _i2.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Film>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Film]s in the list and returns the inserted rows.
  ///
  /// The returned [Film]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Film>> insert(
    _i2.DatabaseSession session,
    List<Film> rows, {
    _i2.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Film>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Film] and returns the inserted row.
  ///
  /// The returned [Film] will have its `id` field set.
  Future<Film> insertRow(
    _i2.DatabaseSession session,
    Film row, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.insertRow<Film>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Film]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Film>> update(
    _i2.DatabaseSession session,
    List<Film> rows, {
    _i2.ColumnSelections<FilmTable>? columns,
    _i2.Transaction? transaction,
  }) async {
    return session.db.update<Film>(
      rows,
      columns: columns?.call(Film.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Film]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Film> updateRow(
    _i2.DatabaseSession session,
    Film row, {
    _i2.ColumnSelections<FilmTable>? columns,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateRow<Film>(
      row,
      columns: columns?.call(Film.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Film] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Film?> updateById(
    _i2.DatabaseSession session,
    _i2.UuidValue id, {
    required _i2.ColumnValueListBuilder<FilmUpdateTable> columnValues,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateById<Film>(
      id,
      columnValues: columnValues(Film.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Film]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Film>> updateWhere(
    _i2.DatabaseSession session, {
    required _i2.ColumnValueListBuilder<FilmUpdateTable> columnValues,
    required _i2.WhereExpressionBuilder<FilmTable> where,
    int? limit,
    int? offset,
    _i2.OrderByBuilder<FilmTable>? orderBy,
    _i2.OrderByListBuilder<FilmTable>? orderByList,
    bool orderDescending = false,
    _i2.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Film>(
      columnValues: columnValues(Film.t.updateTable),
      where: where(Film.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Film.t),
      orderByList: orderByList?.call(Film.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Film]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Film>> delete(
    _i2.DatabaseSession session,
    List<Film> rows, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.delete<Film>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Film].
  Future<Film> deleteRow(
    _i2.DatabaseSession session,
    Film row, {
    _i2.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Film>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Film>> deleteWhere(
    _i2.DatabaseSession session, {
    required _i2.WhereExpressionBuilder<FilmTable> where,
    _i2.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Film>(
      where: where(Film.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i2.DatabaseSession session, {
    _i2.WhereExpressionBuilder<FilmTable>? where,
    int? limit,
    _i2.Transaction? transaction,
  }) async {
    return session.db.count<Film>(
      where: where?.call(Film.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Film] rows matching the [where] expression.
  Future<void> lockRows(
    _i2.DatabaseSession session, {
    required _i2.WhereExpressionBuilder<FilmTable> where,
    required _i2.LockMode lockMode,
    required _i2.Transaction transaction,
    _i2.LockBehavior lockBehavior = _i2.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Film>(
      where: where(Film.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
