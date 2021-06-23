import 'dart:async';
import 'dart:convert';

import 'package:flutter_parse/src/config/config.dart';
import 'package:http/http.dart' as http;

import '../flutter_parse.dart';
import 'http/http.dart';
import 'log/log.dart' as log;
import 'parse_exception.dart';
import 'parse_user.dart';

final ParseHTTPClient parseHTTPClient = ParseHTTPClient._internal();

class ParseHTTPClient {
  ParseHTTPClient._internal()
      : assert(parse.configuration != null),
        this._httpClient =
            parse.configuration!.httpClient ?? ParseBaseHTTPClient();

  final http.BaseClient _httpClient;

  String _getFullUrl(String path) {
    assert(parse.configuration != null);
    return parse.configuration!.uri.origin + path;
  }

  Future<Map<String, String>> _addHeader(
    Map<String, String>? additionalHeaders, {
    bool useMasterKey = false,
  }) async {
    assert(parse.applicationId != null);
    final headers = additionalHeaders ?? <String, String>{};

    if (kOverrideUserAgentHeaderRequest) {
      headers["User-Agent"] = "Dart Parse SDK v$kParseSdkVersion";
    }
    if (parse.applicationId != null) {
      headers['X-Parse-Application-Id'] = parse.applicationId!;
    }

    // client key can be null with self-hosted Parse Server
    if (!useMasterKey && parse.clientKey != null) {
      headers['X-Parse-Client-Key'] = parse.clientKey!;
    }
    if (useMasterKey && parse.masterKey != null) {
      headers['X-Parse-Master-Key'] = parse.masterKey!;
    }

    headers['X-Parse-Client-Version'] = "dart$kParseSdkVersion";

    if (!headers.containsKey('X-Parse-Revocable-Session')) {
      final currentUser = await ParseUser.currentUser;
      if (currentUser != null && currentUser.sessionId != null) {
        headers['X-Parse-Session-Token'] = currentUser.sessionId!;
      }
    }

    return headers;
  }

  Future<dynamic>? _parseResponse(http.Response httpResponse,
      {bool ignoreResult = false}) {
    String response = httpResponse.body;
    if (ignoreResult) {
      return null;
    }

    dynamic result;
    try {
      result = json.decode(response);

      if (parse.enableLogging) {
        print("╭-- JSON");
        _parseLogWrapped(response);
        print("╰-- result");
      }
    } catch (_) {
      if (parse.enableLogging) {
        print("╭-- RESPONSE");
        _parseLogWrapped(response);
        print("╰-- result");
      }
    }

    if (result is Map<String, dynamic>) {
      String? error = result['error'];
      if (error != null) {
        int code = result['code'];
        throw ParseException(code: code, message: error);
      }

      return Future.value(result);
    } else if (result is List<dynamic>) {
      return Future.value(result);
    }

    throw ParseException(
      code: ParseException.invalidJson,
      message: 'invalid server response',
      data: response,
    );
  }

  Future<dynamic> get(
    String path, {
    bool useMasterKey = false,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) async {
    headers = await _addHeader(headers, useMasterKey: useMasterKey);
    final url = _getFullUrl(path);

    if (params != null) {
      final uri = Uri.parse(url).replace(queryParameters: params);
      return _httpClient
          .get(uri, headers: headers)
          .then((r) => _parseResponse(r));
    }

    return _httpClient
        .get(Uri.parse(url), headers: headers)
        .then((r) => _parseResponse(r));
  }

  Future<dynamic> delete(
    String path, {
    bool useMasterKey = false,
    Map<String, String>? params,
    Map<String, String>? headers,
  }) async {
    headers = await _addHeader(headers, useMasterKey: useMasterKey);
    final url = _getFullUrl(path);

    if (params != null) {
      var uri = Uri.parse(url).replace(queryParameters: params);
      return _httpClient.delete(uri, headers: headers).then((r) {
        return _parseResponse(r);
      });
    }

    return _httpClient
        .delete(Uri.parse(url), headers: headers)
        .then((r) => _parseResponse(r));
  }

  Future<dynamic> post(
    String path, {
    bool useMasterKey = false,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    bool ignoreResult = false,
  }) async {
    headers = await _addHeader(headers, useMasterKey: useMasterKey);
    final url = _getFullUrl(path);

    return _httpClient
        .post(Uri.parse(url), headers: headers, body: body, encoding: encoding)
        .then((r) => _parseResponse(r, ignoreResult: ignoreResult));
  }

  Future<dynamic> put(
    String path, {
    bool useMasterKey = false,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
  }) async {
    headers = await _addHeader(headers, useMasterKey: useMasterKey);
    final url = _getFullUrl(path);

    return _httpClient
        .put(Uri.parse(url), headers: headers, body: body, encoding: encoding)
        .then((r) => _parseResponse(r));
  }
}

void logToCURL(http.BaseRequest request) {
  var curlCmd = "curl -X ${request.method} \\\n";
  var compressed = false;
  var bodyAsText = false;
  request.headers.forEach((name, value) {
    if (name.toLowerCase() == "accept-encoding" &&
        value.toLowerCase() == "gzip") {
      compressed = true;
    } else if (name.toLowerCase() == "content-type") {
      bodyAsText =
          value.contains('application/json') || value.contains('text/plain');
    }
    curlCmd += ' -H "$name: $value" \\\n';
  });
  if (<String>['POST', 'PUT', 'PATCH'].contains(request.method)) {
    if (request is http.Request) {
      curlCmd +=
          " -d '${bodyAsText ? request.body : base64Encode(request.bodyBytes)}' \\\n  ";
    }
  }
  curlCmd += (compressed ? " --compressed " : " ") + request.url.toString();
  print("╭-- cURL");
  _parseLogWrapped(curlCmd);
  print("╰-- (copy and paste the above line to a terminal)");
}

void _parseLogWrapped(String text) {
  log.parseLogWrapped(text);
}
