import 'dart:async';

import 'package:http/http.dart' as http;

class ParseBaseHTTPClient extends http.BaseClient {
  ParseBaseHTTPClient() {
    throw UnsupportedError(
        'Cannot create a client without dart:html or dart:io.');
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw UnsupportedError(
        'Cannot create a client without dart:html or dart:io.');
  }
}
