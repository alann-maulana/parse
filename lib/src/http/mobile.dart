import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../flutter_parse.dart';
import '../parse_http_client.dart';

class ParseBaseHTTPClient extends IOClient {
  final IOClient _client;

  ParseBaseHTTPClient()
      : this._client =
            IOClient(HttpClient()..connectionTimeout = Duration(seconds: 20));

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) {
    if (parse.enableLogging) {
      logToCURL(request);
    }

    return _client.send(request);
  }
}
