import 'dart:async';

import '../parse_live_query.dart';

export 'unsupported.dart'
    if (dart.library.io) 'io.dart'
    if (dart.library.html) 'browser.dart';

final Map<int, ParseLiveQuerySubscription> mapRequestSubscription = {};
int requestIdCounter = 1;

typedef ParseLiveQueryCallback = void Function(Object object);

abstract class ParseBaseLiveQueryClient {
  Future<void> connect(ParseLiveQueryCallback callback);

  Future<void> disconnect();

  bool get isConnected;

  void sendMessage(dynamic message);
}
