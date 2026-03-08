import 'package:serverpod/serverpod.dart' as _i1;

abstract class CinemaResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
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
  Map<String, dynamic> toJson() => toJsonForProtocol();
  @override
  Map<String, dynamic> toJsonForProtocol() {
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

  @override
  CinemaResponse copyWith({
    String? id,
    String? name,
    String? city,
    String? address,
  }) {
    return CinemaResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address ?? this.address,
    );
  }
}
