import 'dart:async';

import 'package:meta/meta.dart';

import '../flutter_parse.dart';
import 'parse_object.dart';
import 'parse_user.dart';

class ParseSession extends ParseObject {
  @visibleForTesting
  ParseSession({String? objectId})
      : super(className: '_Session', objectId: objectId);

  factory ParseSession.fromJson({dynamic json}) {
    // ignore: invalid_use_of_visible_for_testing_member
    return ParseSession()..mergeJson(json);
  }

  DateTime? get expiresAt => getDateTime('expiresAt');

  bool? get restricted => getBoolean('restricted');

  /// `createdWith` (readonly): Information about how this session was created
  Map<String, dynamic>? get createdWith => getMap<dynamic>('createdWith');

  /// `action` could have values: `login`, `signup`, `create`, or `upgrade`.
  /// The create action is when the developer manually creates the session by
  /// saving a `Session` object. The `upgrade` action is when the user is
  /// upgraded to revocable session from a legacy session token.
  String get action => createdWith == null ? null : createdWith!['action'];

  /// `authProvider` could have values: `password`, `anonymous`, `facebook`, or `twitter`.
  String get authProvider =>
      createdWith == null ? null : createdWith!['authProvider'];

  ParseUser? get user => getParseUser('user');

  String? get sessionToken => getString('sessionToken');

  static Future<ParseSession> me() async {
    final session = ParseSession(objectId: 'me');
    await session.fetch();
    return session;
  }

  @override
  String get path {
    assert(parse.configuration != null);
    String path = '${parse.configuration!.uri.path}/sessions';

    if (objectId != null) {
      path = '$path/$objectId';
    }

    return path;
  }
}
