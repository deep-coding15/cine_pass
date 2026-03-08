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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'package:cine_pass_client/src/protocol/protocol.dart' as _i2;

abstract class EventResponse implements _i1.SerializableModel {
  EventResponse._({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.location,
    this.address,
    required this.city,
    required this.date,
    required this.time,
    required this.placesLeft,
    required this.placesTotal,
    required this.price,
    this.posterColor,
    this.availableOptions,
  });

  factory EventResponse({
    required String id,
    required String title,
    required String category,
    String? description,
    required String location,
    String? address,
    required String city,
    required String date,
    required String time,
    required int placesLeft,
    required int placesTotal,
    required double price,
    int? posterColor,
    List<String>? availableOptions,
  }) = _EventResponseImpl;

  factory EventResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return EventResponse(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      category: jsonSerialization['category'] as String,
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String,
      address: jsonSerialization['address'] as String?,
      city: jsonSerialization['city'] as String,
      date: jsonSerialization['date'] as String,
      time: jsonSerialization['time'] as String,
      placesLeft: jsonSerialization['placesLeft'] as int,
      placesTotal: jsonSerialization['placesTotal'] as int,
      price: (jsonSerialization['price'] as num).toDouble(),
      posterColor: jsonSerialization['posterColor'] as int?,
      availableOptions: jsonSerialization['availableOptions'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['availableOptions'],
            ),
    );
  }

  String id;

  String title;

  String category;

  String? description;

  String location;

  String? address;

  String city;

  String date;

  String time;

  int placesLeft;

  int placesTotal;

  double price;

  int? posterColor;

  List<String>? availableOptions;

  /// Returns a shallow copy of this [EventResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventResponse copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? location,
    String? address,
    String? city,
    String? date,
    String? time,
    int? placesLeft,
    int? placesTotal,
    double? price,
    int? posterColor,
    List<String>? availableOptions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventResponse',
      'id': id,
      'title': title,
      'category': category,
      if (description != null) 'description': description,
      'location': location,
      if (address != null) 'address': address,
      'city': city,
      'date': date,
      'time': time,
      'placesLeft': placesLeft,
      'placesTotal': placesTotal,
      'price': price,
      if (posterColor != null) 'posterColor': posterColor,
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

class _EventResponseImpl extends EventResponse {
  _EventResponseImpl({
    required String id,
    required String title,
    required String category,
    String? description,
    required String location,
    String? address,
    required String city,
    required String date,
    required String time,
    required int placesLeft,
    required int placesTotal,
    required double price,
    int? posterColor,
    List<String>? availableOptions,
  }) : super._(
         id: id,
         title: title,
         category: category,
         description: description,
         location: location,
         address: address,
         city: city,
         date: date,
         time: time,
         placesLeft: placesLeft,
         placesTotal: placesTotal,
         price: price,
         posterColor: posterColor,
         availableOptions: availableOptions,
       );

  /// Returns a shallow copy of this [EventResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventResponse copyWith({
    String? id,
    String? title,
    String? category,
    Object? description = _Undefined,
    String? location,
    Object? address = _Undefined,
    String? city,
    String? date,
    String? time,
    int? placesLeft,
    int? placesTotal,
    double? price,
    Object? posterColor = _Undefined,
    Object? availableOptions = _Undefined,
  }) {
    return EventResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description is String? ? description : this.description,
      location: location ?? this.location,
      address: address is String? ? address : this.address,
      city: city ?? this.city,
      date: date ?? this.date,
      time: time ?? this.time,
      placesLeft: placesLeft ?? this.placesLeft,
      placesTotal: placesTotal ?? this.placesTotal,
      price: price ?? this.price,
      posterColor: posterColor is int? ? posterColor : this.posterColor,
      availableOptions: availableOptions is List<String>?
          ? availableOptions
          : this.availableOptions?.map((e0) => e0).toList(),
    );
  }
}
