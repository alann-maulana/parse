import 'dart:convert';

class ParseGeoPoint {
  ParseGeoPoint({double latitude = 0.0, double longitude = 0.0}) {
    this.latitude = latitude;
    this.longitude = longitude;
  }

  late double _latitude;
  late double _longitude;

  double get latitude => _latitude;

  double get longitude => _longitude;

  set latitude(double value) {
    assert(value >= -90.0 || value <= 90.0);
    _latitude = value;
  }

  set longitude(double value) {
    assert(value >= -180.0 || value <= 180.0);
    _longitude = value;
  }

  get asMap => <String, dynamic>{
        '__type': 'GeoPoint',
        'latitude': _latitude,
        'longitude': _longitude
      };

  @override
  String toString() {
    return json.encode(asMap);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParseGeoPoint &&
          runtimeType == other.runtimeType &&
          _latitude == other._latitude &&
          _longitude == other._longitude;

  @override
  int get hashCode => _latitude.hashCode ^ _longitude.hashCode;
}
