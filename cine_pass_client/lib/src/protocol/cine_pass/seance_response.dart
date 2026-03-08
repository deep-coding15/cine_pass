import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class SeanceResponse implements _i1.SerializableModel {
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
      availableOptions: (jsonSerialization['availableOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
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

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeanceResponse',
      'id': id,
      'cinemaName': cinemaName,
      'location': location,
      'room': room,
      'dateTime': dateTime,
      'format': format,
      'type': type,
      'placesLeft': placesLeft,
      'placesTotal': placesTotal,
      'price': price,
      'availableOptions': availableOptions,
    };
  }
}

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
}
