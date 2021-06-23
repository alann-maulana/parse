import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_parse/flutter_parse.dart' show parse, ParseException;
import 'package:web_socket_channel/io.dart';

import 'live_query.dart';

final ParseLiveQueryClient parseLiveQueryClient = ParseLiveQueryClient();

class ParseLiveQueryClient extends ParseBaseLiveQueryClient {
  late WebSocket _webSocket;
  IOWebSocketChannel? _channel;
  bool _userDisconnected = false;

  Future<void> connect(ParseLiveQueryCallback callback) async {
    assert(parse.configuration != null &&
        parse.configuration!.liveQueryServer != null);
    _userDisconnected = false;
    final server = parse.configuration!.liveQueryServer!;
    try {
      if (parse.enableLogging == true) {
        print('Connecting web socket');
      }
      _webSocket = await WebSocket.connect(server);
      if (_webSocket.readyState == WebSocket.open) {
        if (parse.enableLogging == true) {
          print('Connecting io web socket');
        }
        _channel = IOWebSocketChannel(_webSocket);
        if (parse.enableLogging == true) {
          print('Listening to stream');
        }
        _channel!.stream.listen(
          (dynamic message) {
            if (parse.enableLogging == true) {
              print('RECEIVE: $message');
            }

            try {
              final Map<String, dynamic> result = json.decode(message);
              callback(result);
            } catch (e) {
              callback(ParseException.fromThrow(e));
            }
          },
          onDone: () {
            if (parse.enableLogging == true) {
              print('Listening done');
            }

            if (!_userDisconnected) {
              if (parse.enableLogging == true) {
                print('Reconnecting');
              }
              connect(callback);
            }
          },
          onError: (error) {
            if (parse.enableLogging == true) {
              print('Listening error: $error');
            }

            if (!_userDisconnected) {
              if (parse.enableLogging == true) {
                print('Reconnecting');
              }
              connect(callback);
            } else {
              callback(ParseException(message: error.toString()));
            }
          },
        );
      } else {
        callback(ParseException(message: 'Failed to connect'));
      }
    } catch (e) {
      callback(ParseException.fromThrow(e));
    }
  }

  bool get isConnected => _channel != null && !_userDisconnected;

  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    if (_webSocket.readyState == WebSocket.open) {
      await _webSocket.close();
    }

    _userDisconnected = true;
  }

  @override
  void sendMessage(dynamic message) {
    if (parse.enableLogging == true) {
      print('SEND: $message');
    }

    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }
}
