import 'dart:async';

import 'live_query.dart';

final ParseLiveQueryClient parseLiveQueryClient = ParseLiveQueryClient();

class ParseLiveQueryClient extends ParseBaseLiveQueryClient {
  ParseLiveQueryClient();

  Future<void> connect(ParseLiveQueryCallback callback) async {
    throw UnsupportedError(
        'Cannot create a client without dart:html or dart:io.');
  }

  bool get isConnected => throw UnsupportedError(
      'Cannot create a client without dart:html or dart:io.');

  @override
  Future<void> disconnect() {
    throw UnsupportedError(
        'Cannot create a client without dart:html or dart:io.');
  }

  @override
  void sendMessage(message) {
    throw UnsupportedError(
        'Cannot create a client without dart:html or dart:io.');
  }
}
