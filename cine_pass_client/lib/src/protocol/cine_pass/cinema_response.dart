import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class CinemaResponse implements _i1.SerializableModel {
  CinemaResponse._({
    required this.id,
    required this.name,
    required this.city,
    this.address,
  });

  factory CinemaResponse({
    required String id,
    required String name,
    required String city,
    String? address,
  }) = _CinemaResponseImpl;

  factory CinemaResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return CinemaResponse(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      city: jsonSerialization['city'] as String,
      address: jsonSerialization['address'] as String?,
    );
  }

  String id;
  String name;
  String city;
  String? address;

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CinemaResponse',
      'id': id,
      'name': name,
      'city': city,
      'address': address,
    };
  }
}

class _CinemaResponseImpl extends CinemaResponse {
  _CinemaResponseImpl({
    required String id,
    required String name,
    required String city,
    String? address,
  }) : super._(id: id, name: name, city: city, address: address);
}
