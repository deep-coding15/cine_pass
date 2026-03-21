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
import 'package:cine_pass_server/src/generated/protocol.dart' as _i2;

abstract class SeanceResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SeanceResponse._({
    required this.id,
    required this.cinemaName,
    required this.location,
    required this.room,
    required this.dateTime,
    this.format,
    this.type,
    required this.placesLeft,
    required this.placesTotal,
    required this.price,
    this.availableOptions,
  });

  factory SeanceResponse({
    required String id,
    required String cinemaName,
    required String location,
    required String room,
    required String dateTime,
    String? format,
    String? type,
    required int placesLeft,
    required int placesTotal,
    required double price,
    List<String>? availableOptions,
  }) = _SeanceResponseImpl;

  factory SeanceResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeanceResponse(
      id: jsonSerialization['id'] as String,
      cinemaName: jsonSerialization['cinemaName'] as String,
      location: jsonSerialization['location'] as String,
      room: jsonSerialization['room'] as String,
      dateTime: jsonSerialization['dateTime'] as String,
      format: jsonSerialization['format'] as String?,
      type: jsonSerialization['type'] as String?,
      placesLeft: jsonSerialization['placesLeft'] as int,
      placesTotal: jsonSerialization['placesTotal'] as int,
      price: (jsonSerialization['price'] as num).toDouble(),
      availableOptions: jsonSerialization['availableOptions'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['availableOptions'],
            ),
    );
  }

  String id;

  String cinemaName;

  String location;

  String room;

  String dateTime;

  String? format;

  String? type;

  int placesLeft;

  int placesTotal;

  double price;

  List<String>? availableOptions;

  /// Returns a shallow copy of this [SeanceResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SeanceResponse copyWith({
    String? id,
    String? cinemaName,
    String? location,
    String? room,
    String? dateTime,
    String? format,
    String? type,
    int? placesLeft,
    int? placesTotal,
    double? price,
    List<String>? availableOptions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeanceResponse',
      'id': id,
      'cinemaName': cinemaName,
      'location': location,
      'room': room,
      'dateTime': dateTime,
      if (format != null) 'format': format,
      if (type != null) 'type': type,
      'placesLeft': placesLeft,
      'placesTotal': placesTotal,
      'price': price,
      if (availableOptions != null)
        'availableOptions': availableOptions?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SeanceResponse',
      'id': id,
      'cinemaName': cinemaName,
      'location': location,
      'room': room,
      'dateTime': dateTime,
      if (format != null) 'format': format,
      if (type != null) 'type': type,
      'placesLeft': placesLeft,
      'placesTotal': placesTotal,
      'price': price,
      if (availableOptions != null)
        'availableOptions': availableOptions?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SeanceResponseImpl extends SeanceResponse {
  _SeanceResponseImpl({
    required String id,
    required String cinemaName,
    required String location,
    required String room,
    required String dateTime,
    String? format,
    String? type,
    required int placesLeft,
    required int placesTotal,
    required double price,
    List<String>? availableOptions,
  }) : super._(
         id: id,
         cinemaName: cinemaName,
         location: location,
         room: room,
         dateTime: dateTime,
         format: format,
         type: type,
         placesLeft: placesLeft,
         placesTotal: placesTotal,
         price: price,
         availableOptions: availableOptions,
       );

  /// Returns a shallow copy of this [SeanceResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SeanceResponse copyWith({
    String? id,
    String? cinemaName,
    String? location,
    String? room,
    String? dateTime,
    Object? format = _Undefined,
    Object? type = _Undefined,
    int? placesLeft,
    int? placesTotal,
    double? price,
    Object? availableOptions = _Undefined,
  }) {
    return SeanceResponse(
      id: id ?? this.id,
      cinemaName: cinemaName ?? this.cinemaName,
      location: location ?? this.location,
      room: room ?? this.room,
      dateTime: dateTime ?? this.dateTime,
      format: format is String? ? format : this.format,
      type: type is String? ? type : this.type,
      placesLeft: placesLeft ?? this.placesLeft,
      placesTotal: placesTotal ?? this.placesTotal,
      price: price ?? this.price,
      availableOptions: availableOptions is List<String>?
          ? availableOptions
          : this.availableOptions?.map((e0) => e0).toList(),
    );
  }
}
