import 'package:serverpod_client/serverpod_client.dart' as _i1;

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
      availableOptions: (jsonSerialization['availableOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
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

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventResponse',
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'location': location,
      'address': address,
      'city': city,
      'date': date,
      'time': time,
      'placesLeft': placesLeft,
      'placesTotal': placesTotal,
      'price': price,
      'posterColor': posterColor,
      'availableOptions': availableOptions,
    };
  }
}

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
}
