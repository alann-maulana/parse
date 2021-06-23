import 'dart:async';

import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

import '../../flutter_parse.dart';
import '../parse_http_client.dart';

class ParseBaseHTTPClient extends BrowserClient {
  final http.Client _client;

  ParseBaseHTTPClient() : this._client = BrowserClient();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (parse.enableLogging) {
      logToCURL(request);
    }

    return await _client.send(request);
  }
}
