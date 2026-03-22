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
    this.posterUrl,
    this.availableOptions,
    this.priceFrom,
    this.priceTo,
    this.reservationMode,
    this.eventType,
    this.eventSubtype,
    this.customTypeLabel,
    this.eventLanguage,
    this.filmGenre,
    this.filmDirector,
    this.festivalTheme,
    this.standupMainArtist,
    this.concertArtist,
    this.concertMusicGenre,
    this.theatreAuthor,
    this.structureName,
    this.archived,
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
    String? posterUrl,
    List<String>? availableOptions,
    double? priceFrom,
    double? priceTo,
    String? reservationMode,
    String? eventType,
    String? eventSubtype,
    String? customTypeLabel,
    String? eventLanguage,
    String? filmGenre,
    String? filmDirector,
    String? festivalTheme,
    String? standupMainArtist,
    String? concertArtist,
    String? concertMusicGenre,
    String? theatreAuthor,
    String? structureName,
    bool? archived,
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
      posterUrl: jsonSerialization['posterUrl'] as String?,
      availableOptions: jsonSerialization['availableOptions'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['availableOptions'],
            ),
      priceFrom: (jsonSerialization['priceFrom'] as num?)?.toDouble(),
      priceTo: (jsonSerialization['priceTo'] as num?)?.toDouble(),
      reservationMode: jsonSerialization['reservationMode'] as String?,
      eventType: jsonSerialization['eventType'] as String?,
      eventSubtype: jsonSerialization['eventSubtype'] as String?,
      customTypeLabel: jsonSerialization['customTypeLabel'] as String?,
      eventLanguage: jsonSerialization['eventLanguage'] as String?,
      filmGenre: jsonSerialization['filmGenre'] as String?,
      filmDirector: jsonSerialization['filmDirector'] as String?,
      festivalTheme: jsonSerialization['festivalTheme'] as String?,
      standupMainArtist: jsonSerialization['standupMainArtist'] as String?,
      concertArtist: jsonSerialization['concertArtist'] as String?,
      concertMusicGenre: jsonSerialization['concertMusicGenre'] as String?,
      theatreAuthor: jsonSerialization['theatreAuthor'] as String?,
      structureName: jsonSerialization['structureName'] as String?,
      archived: jsonSerialization['archived'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['archived']),
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

  String? posterUrl;

  List<String>? availableOptions;

  double? priceFrom;

  double? priceTo;

  String? reservationMode;

  String? eventType;

  String? eventSubtype;

  String? customTypeLabel;

  String? eventLanguage;

  String? filmGenre;

  String? filmDirector;

  String? festivalTheme;

  String? standupMainArtist;

  String? concertArtist;

  String? concertMusicGenre;

  String? theatreAuthor;

  String? structureName;

  bool? archived;

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
    String? posterUrl,
    List<String>? availableOptions,
    double? priceFrom,
    double? priceTo,
    String? reservationMode,
    String? eventType,
    String? eventSubtype,
    String? customTypeLabel,
    String? eventLanguage,
    String? filmGenre,
    String? filmDirector,
    String? festivalTheme,
    String? standupMainArtist,
    String? concertArtist,
    String? concertMusicGenre,
    String? theatreAuthor,
    String? structureName,
    bool? archived,
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
      if (posterUrl != null) 'posterUrl': posterUrl,
      if (availableOptions != null)
        'availableOptions': availableOptions?.toJson(),
      if (priceFrom != null) 'priceFrom': priceFrom,
      if (priceTo != null) 'priceTo': priceTo,
      if (reservationMode != null) 'reservationMode': reservationMode,
      if (eventType != null) 'eventType': eventType,
      if (eventSubtype != null) 'eventSubtype': eventSubtype,
      if (customTypeLabel != null) 'customTypeLabel': customTypeLabel,
      if (eventLanguage != null) 'eventLanguage': eventLanguage,
      if (filmGenre != null) 'filmGenre': filmGenre,
      if (filmDirector != null) 'filmDirector': filmDirector,
      if (festivalTheme != null) 'festivalTheme': festivalTheme,
      if (standupMainArtist != null) 'standupMainArtist': standupMainArtist,
      if (concertArtist != null) 'concertArtist': concertArtist,
      if (concertMusicGenre != null) 'concertMusicGenre': concertMusicGenre,
      if (theatreAuthor != null) 'theatreAuthor': theatreAuthor,
      if (structureName != null) 'structureName': structureName,
      if (archived != null) 'archived': archived,
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
    String? posterUrl,
    List<String>? availableOptions,
    double? priceFrom,
    double? priceTo,
    String? reservationMode,
    String? eventType,
    String? eventSubtype,
    String? customTypeLabel,
    String? eventLanguage,
    String? filmGenre,
    String? filmDirector,
    String? festivalTheme,
    String? standupMainArtist,
    String? concertArtist,
    String? concertMusicGenre,
    String? theatreAuthor,
    String? structureName,
    bool? archived,
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
         posterUrl: posterUrl,
         availableOptions: availableOptions,
         priceFrom: priceFrom,
         priceTo: priceTo,
         reservationMode: reservationMode,
         eventType: eventType,
         eventSubtype: eventSubtype,
         customTypeLabel: customTypeLabel,
         eventLanguage: eventLanguage,
         filmGenre: filmGenre,
         filmDirector: filmDirector,
         festivalTheme: festivalTheme,
         standupMainArtist: standupMainArtist,
         concertArtist: concertArtist,
         concertMusicGenre: concertMusicGenre,
         theatreAuthor: theatreAuthor,
         structureName: structureName,
         archived: archived,
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
    Object? posterUrl = _Undefined,
    Object? availableOptions = _Undefined,
    Object? priceFrom = _Undefined,
    Object? priceTo = _Undefined,
    Object? reservationMode = _Undefined,
    Object? eventType = _Undefined,
    Object? eventSubtype = _Undefined,
    Object? customTypeLabel = _Undefined,
    Object? eventLanguage = _Undefined,
    Object? filmGenre = _Undefined,
    Object? filmDirector = _Undefined,
    Object? festivalTheme = _Undefined,
    Object? standupMainArtist = _Undefined,
    Object? concertArtist = _Undefined,
    Object? concertMusicGenre = _Undefined,
    Object? theatreAuthor = _Undefined,
    Object? structureName = _Undefined,
    Object? archived = _Undefined,
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
      posterUrl: posterUrl is String? ? posterUrl : this.posterUrl,
      availableOptions: availableOptions is List<String>?
          ? availableOptions
          : this.availableOptions?.map((e0) => e0).toList(),
      priceFrom: priceFrom is double? ? priceFrom : this.priceFrom,
      priceTo: priceTo is double? ? priceTo : this.priceTo,
      reservationMode: reservationMode is String?
          ? reservationMode
          : this.reservationMode,
      eventType: eventType is String? ? eventType : this.eventType,
      eventSubtype: eventSubtype is String? ? eventSubtype : this.eventSubtype,
      customTypeLabel: customTypeLabel is String?
          ? customTypeLabel
          : this.customTypeLabel,
      eventLanguage: eventLanguage is String?
          ? eventLanguage
          : this.eventLanguage,
      filmGenre: filmGenre is String? ? filmGenre : this.filmGenre,
      filmDirector: filmDirector is String? ? filmDirector : this.filmDirector,
      festivalTheme: festivalTheme is String?
          ? festivalTheme
          : this.festivalTheme,
      standupMainArtist: standupMainArtist is String?
          ? standupMainArtist
          : this.standupMainArtist,
      concertArtist: concertArtist is String?
          ? concertArtist
          : this.concertArtist,
      concertMusicGenre: concertMusicGenre is String?
          ? concertMusicGenre
          : this.concertMusicGenre,
      theatreAuthor: theatreAuthor is String?
          ? theatreAuthor
          : this.theatreAuthor,
      structureName: structureName is String?
          ? structureName
          : this.structureName,
      archived: archived is bool? ? archived : this.archived,
    );
  }
}
