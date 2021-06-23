import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import '../flutter_parse.dart';
import 'livequery/live_query.dart';
import 'parse_exception.dart';

ParseLiveQuery parseLiveQuery = ParseLiveQuery();

class ParseLiveQuery {
  String? _clientId;

  @protected
  ParseLiveQuery();

  Future<void> connect() async {
    await parseLiveQueryClient.connect(_callback);
  }

  Future<void> disconnect() async {
    await parseLiveQueryClient.disconnect();
  }

  _callback(Object? object) {
    if (object is Exception) {
      throw object;
    }

    if (object == null || object is! Map<String, dynamic>) {
      // TODO: result is empty
      return;
    }

    final Map<String, dynamic> result = object;

    final String op = result['op'];

    if (op == 'connected') {
      _clientId = result['clientId'];
      return;
    }

    ParseLiveQuerySubscription? subscription;
    if (result.containsKey('requestId')) {
      final int requestId = result['requestId'];
      subscription = mapRequestSubscription[requestId];
    }

    if (subscription == null) {
      return;
    }

    final callback = subscription.mapOperationCallback[op];

    if (op == 'error') {
      final int code = result['code'];
      final String error = result['error'];

      if (callback != null) {
        callback(ParseException(code: code, message: error));
      }
      return;
    }

    if (result.containsKey('object')) {
      if (callback == null) return;
      final Map<String, dynamic> map = result['object'];
      final String className = map['className'];
      if (className == '_User') {
        callback(ParseUser.fromJson(json: map));
      } else {
        // ignore: invalid_use_of_visible_for_testing_member
        callback(ParseObject.fromJson(json: map));
      }
    }
  }

  Future<void> connectMessage() async {
    if (!parseLiveQueryClient.isConnected) {
      return;
    }

    final bodyMessage = <String, String>{
      'op': 'connect',
    };

    if (parse.applicationId != null) {
      bodyMessage['applicationId'] = parse.applicationId!;
    }

    final user = await ParseUser.currentUser;

    if (user != null && user.sessionId != null) {
      bodyMessage['sessionToken'] = user.sessionId!;
    }

    if (parse.clientKey != null) {
      bodyMessage['clientKey'] = parse.clientKey!;
    }

    if (parse.masterKey != null) {
      bodyMessage['masterKey'] = parse.masterKey!;
    }

    parseLiveQueryClient.sendMessage(json.encode(bodyMessage));
  }

  Future<ParseLiveQuerySubscription> subscribe(
    ParseQuery<ParseObject> query, {
    ParseLiveQuerySubscription? subscription,
  }) async {
    final selectedKeys = query.selectedKeys;
    final Map<String, dynamic>? where = query.toJsonParams()['where'];
    subscription ??= ParseLiveQuerySubscription(
      clientId: _clientId,
      requestId: requestIdCounter++,
      parseQuery: query,
    );

    if (subscription.requestId != null) {
      mapRequestSubscription[subscription.requestId!] = subscription;
    }

    final subscribeMessage = <String, dynamic>{
      'op': 'subscribe',
      'requestId': subscription.requestId,
      'query': <String, dynamic>{
        'className': query.className,
        'where': where ?? {},
      }
    };

    if (selectedKeys != null && selectedKeys.isNotEmpty) {
      subscribeMessage['fields'] = selectedKeys;
    }

    final user = await ParseUser.currentUser;
    if (user != null && user.sessionId != null) {
      subscribeMessage['sessionToken'] = user.sessionId;
    }

    parseLiveQueryClient.sendMessage(json.encode(subscribeMessage));

    return subscription;
  }

  Future<void> unsubscribe(ParseLiveQuerySubscription subscription) async {
    final unsubscribeMessage = <String, dynamic>{
      'op': 'unsubscribe',
      'requestId': subscription.requestId,
    };

    if (parseLiveQueryClient.isConnected) {
      parseLiveQueryClient.sendMessage(json.encode(unsubscribeMessage));
      mapRequestSubscription.remove(subscription.requestId);
    }
  }
}

class ParseLiveQuerySubscription {
  final Map<String, ParseLiveQueryCallback?> mapOperationCallback = {};
  final String? clientId;
  final ParseQuery? parseQuery;
  final int? requestId;

  ParseLiveQuerySubscription({
    this.clientId,
    this.requestId,
    this.parseQuery,
  });

  void on(ParseLiveQueryEvent op, {ParseLiveQueryCallback? callback}) {
    mapOperationCallback[op.value] = callback;
  }

  @override
  String toString() {
    return 'ParseLiveQuerySubscription{clientId: $clientId, parseQuery: ${parseQuery?.toJsonParams()}, requestId: $requestId}';
  }
}

class ParseLiveQueryEvent {
  final String value;

  const ParseLiveQueryEvent._(this.value);

  static const create = ParseLiveQueryEvent._('create');
  static const enter = ParseLiveQueryEvent._('enter');
  static const update = ParseLiveQueryEvent._('update');
  static const leave = ParseLiveQueryEvent._('leave');
  static const delete = ParseLiveQueryEvent._('delete');
  static const error = ParseLiveQueryEvent._('error');

  static const values = <ParseLiveQueryEvent>[
    create,
    enter,
    update,
    leave,
    delete,
    error
  ];
}
