import 'package:flutter_parse/flutter_parse.dart';
import 'package:flutter_parse/src/parse_date_format.dart';

import 'parse_acl.dart';

class ParseRole {
  ParseRole.fromMap(dynamic map)
      : objectId = map['objectId'],
        name = map['name'],
        acl = ParseACL.fromMap(map['ACL']),
        createdAt = map['createdAt'] == null
            ? null
            : parseDateFormat.parse(map['createdAt']),
        updatedAt = map['updatedAt'] == null
            ? null
            : parseDateFormat.parse(map['updatedAt']);

  final String? objectId;
  final String name;
  final ParseACL acl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  get asMap => <String, dynamic>{
        '__type': 'Pointer',
        'className': '_Role',
        'objectId': objectId,
      };

  static ParseQuery get query => ParseQuery(className: '_Role');
}
