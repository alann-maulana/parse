import 'dart:convert';

import 'package:flutter_parse/flutter_parse.dart';

import 'parse_date_format.dart';
import 'parse_file.dart';
import 'parse_geo_point.dart';
import 'parse_object.dart';
import 'parse_session.dart';
import 'parse_user.dart';

final ParseDecoder parseDecoder = ParseDecoder._internal();

/// A [ParseDecoder] can be used to transform JSON data structures into actual objects, such as [ParseObject]
class ParseDecoder {
  ParseDecoder._internal();

  List<dynamic> _convertJSONArrayToList(List<dynamic> array) {
    List<dynamic> list = [];
    array.forEach((value) {
      list.add(decode(value));
    });
    return list;
  }

  Map<String, dynamic> _convertJSONObjectToMap(Map<String, dynamic> object) {
    Map<String, dynamic> map = Map();
    object.forEach((key, value) {
      map.putIfAbsent(key, () => decode(value));
    });
    return map;
  }

  /// Decode any type value
  dynamic decode(dynamic value) {
    if (value is List) {
      return _convertJSONArrayToList(value);
    }

    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value.toInt();
    }

    if (value is double) {
      return value.toDouble();
    }

    if (value is num) {
      return value;
    }

    if (!(value is Map<String, dynamic>)) {
      return value;
    }

    Map<String, dynamic> map = value;
    if (!map.containsKey("__type")) {
      return _convertJSONObjectToMap(map);
    }

    switch (map["__type"]) {
      case "Date":
        String iso = map["iso"];
        return parseDateFormat.parse(iso);
      case "Bytes":
        String val = map["base64"];
        return base64.decode(val);
      case "Pointer":
        String objectId = map["objectId"];
        String className = map["className"];
        if (className == '_User') {
          return ParseUser(objectId: objectId);
        } else if (className == '_Role') {
          return ParseRole.fromMap(map);
        }
        return ParseObject(className: className, objectId: objectId);
      case "Object":
        String objectId = map["objectId"];
        String className = map["className"];
        if (className == '_Session') {
          return ParseSession.fromJson(json: map);
        }
        if (className == '_User') {
          return ParseUser.fromJson(json: map);
        }
        // ignore: invalid_use_of_visible_for_testing_member
        return ParseObject.fromJson(
          className: className,
          objectId: objectId,
          json: map,
        );
      case "File":
        // ignore: invalid_use_of_visible_for_testing_member
        return ParseFile.fromJson(map);
      case "GeoPoint":
        num latitude = map["latitude"] ?? 0.0;
        num longitude = map["longitude"] ?? 0.0;
        return ParseGeoPoint(
          latitude: latitude.toDouble(),
          longitude: longitude.toDouble(),
        );
    }

    return null;
  }
}
