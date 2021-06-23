import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_parse/flutter_parse.dart';

import 'parse_acl.dart';
import 'parse_date_format.dart';
import 'parse_file.dart';
import 'parse_geo_point.dart';
import 'parse_object.dart';
import 'parse_query.dart';

final ParseEncoder parseEncoder = ParseEncoder._internal();

/// A [ParseEncoder] can be used to transform objects such as [ParseObject] into Map
/// data structures.
class ParseEncoder {
  ParseEncoder._internal();

  isValidType(dynamic value) {
    assert(value == null ||
        value is String ||
        value is num ||
        value is bool ||
        value is DateTime ||
        value is List ||
        value is Map ||
        value is Uint8List ||
        value is ParseACL ||
        value is ParseObject ||
        value is ParseFile ||
        value is ParseGeoPoint);
  }

  /// Encode any type value into Map
  dynamic encode(dynamic value) {
    if (value is DateTime) {
      return _encodeDate(value);
    }

    if (value is Uint8List) {
      return _encodeUint8List(value);
    }

    if (value is List) {
      return value.map((v) => encode(v)).toList();
    }

    if (value is Map) {
      Map<String, dynamic> map = {};
      value.forEach((k, v) {
        map[k] = encode(v);
      });
      return map;
    }

    if (value is ParseObject) {
      return value.asPointer;
    }

    if (value is ParseQuery) {
      return value.toJson();
    }

    if (value is ParseFile) {
      return value.asMap;
    }

    if (value is ParseGeoPoint) {
      return value.asMap;
    }

    if (value is ParseACL) {
      return value.map;
    }

    if (value is ParseRole) {
      return value.asMap;
    }

    return value;
  }

  Map<String, dynamic> _encodeUint8List(Uint8List value) {
    return <String, dynamic>{"__type": "Bytes", "base64": base64.encode(value)};
  }

  Map<String, dynamic> _encodeDate(DateTime date) {
    return <String, dynamic>{
      "__type": "Date",
      "iso": parseDateFormat.format(date)
    };
  }
}
