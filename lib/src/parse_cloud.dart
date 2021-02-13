import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import '../flutter_parse.dart';
import 'parse_base_object.dart';
import 'parse_http_client.dart';

class ParseCloud extends ParseBaseObject {
  ParseCloud.functions({
    @required this.method,
    this.body = const {},
  }) : this.type = 'functions';

  ParseCloud.jobs({
    @required this.method,
    this.body = const {},
  }) : this.type = 'jobs';

  final dynamic body;

  final String method;

  final String type;

  @override
  get asMap => body;

  @override
  String get path => '${parse.configuration.uri.path}/$type/$method';

  Future<dynamic> execute({bool useMasterKey = false}) async {
    assert(useMasterKey != null, 'Master key cannot be null');
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    final response = await parseHTTPClient.post(
      path,
      body: json.encode(body),
      headers: headers,
      useMasterKey: useMasterKey,
    );
    final result = response['result'];

    if (result is List) {
      return result;
    } else if (result is Map) {
      final error = result['error'];
      final code = result['code'];
      if (error != null) {
        throw ParseException(code: code, message: error);
      }

      return result;
    } else if (result is int) {
      return result;
    } else if (result is String) {
      return result;
    }

    return null;
  }
}
