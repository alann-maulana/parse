import 'dart:async';

import 'package:meta/meta.dart';

import '../flutter_parse.dart';
import 'parse_base_object.dart';
import 'parse_http_client.dart';

class ParseSchema implements ParseBaseObject {
  ParseSchema({required this.className});

  final String className;
  List<Schema>? _schemas;

  List<Schema>? get schemas => _schemas;

  @visibleForTesting
  void setSchemas(List<dynamic>? values) {
    _schemas = values?.map((map) => Schema.fromJson(map)).toList();
  }

  @override
  get asMap => _schemas?.map((s) => s.asMap).toList();

  @override
  String get path {
    assert(parse.configuration != null);
    String path = '${parse.configuration!.uri.path}/schemas';
    path = '$path/$className';
    return path;
  }

  Future<List<Schema>?> fetch() async {
    final result = await parseHTTPClient.get(path, useMasterKey: true);
    setSchemas(result['results']);
    return schemas;
  }
}

class Schema {
  Schema.fromJson(dynamic map)
      : className = map['className'],
        fields = _parseFields(map['fields']),
        classLevelPermissions = map['classLevelPermissions'],
        indexes = map['indexes'];

  final String className;
  final Map<String, SchemaType>? fields;
  final Map<String, dynamic> classLevelPermissions;
  final Map<String, dynamic> indexes;

  static Map<String, SchemaType>? _parseFields(dynamic json) {
    if (json is Map) {
      final map = <String, SchemaType>{};
      json.forEach((key, value) {
        map[key] = SchemaType.fromJson(value);
      });
      return map;
    }

    return null;
  }

  dynamic get asMap => <String, dynamic>{
        'className': className,
        'fields': fields,
        'classLevelPermissions': classLevelPermissions,
        'indexes': indexes,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParseSchema &&
          runtimeType == other.runtimeType &&
          className == other.className;

  @override
  int get hashCode => className.hashCode;
}

class SchemaType {
  SchemaType(this.type, [this.targetClass]);

  SchemaType.fromJson(dynamic map) : this(map['type'], map['targetClass']);

  final String type;
  final String? targetClass;

  dynamic get asMap => <String, dynamic>{
        'type': type,
        'targetClass': targetClass,
      };
}
