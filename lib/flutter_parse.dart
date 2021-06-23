// Copyright (c) 2018, the Flutter Parse project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.
/// Dart package for accessing Parse Server
library flutter_parse;

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

import 'src/parse_http_client.dart' as client;
import 'src/platform/platform.dart';

export 'src/parse_acl.dart';
export 'src/parse_cloud.dart';
export 'src/parse_config.dart';
export 'src/parse_exception.dart';
export 'src/parse_file.dart';
export 'src/parse_geo_point.dart';
export 'src/parse_live_query.dart';
export 'src/parse_object.dart';
export 'src/parse_query.dart';
export 'src/parse_role.dart';
export 'src/parse_schema.dart';
export 'src/parse_session.dart';
export 'src/parse_user.dart';

/// Displaying current Parse SDK version
const String kParseSdkVersion = "0.2.4";

final Parse parse = Parse._internal();

/// The [Parse] class contains static functions that handle global
/// configuration for the Parse library.
class Parse {
  Parse._internal();

  /// Authenticates this client as belonging to your application.
  /// This must be called before your application can use the Parse library.
  ///
  /// The recommended way is to put a call to
  /// [Parse.initialize] in your `main`'s method:
  ///
  /// ```
  /// void main() {
  ///   ParseConfiguration config = ParseConfiguration(
  ///     server: 'YOUR_PARSE_SERVER_URL',
  ///     applicationId: 'YOUR_PARSE_APPLICATION_ID',
  ///     clientKey: 'YOUR_PARSE_CLIENT_KEY',
  ///   );
  ///   Parse.initialize(config);
  ///   runApp(MyApp());
  /// }
  /// ```
  factory Parse.initialize(ParseConfiguration configuration) {
    return parse..initialize(configuration);
  }

  /// Setter method for [ParseConfiguration] using [parse] global instance
  void initialize(ParseConfiguration configuration) {
    _configuration = configuration;
  }

  ParseConfiguration? _configuration;

  ParseConfiguration? get configuration => _configuration;

  /// Return [Parse] client key
  String? get clientKey => configuration?.clientKey;

  /// Return [Parse] master key
  String? get masterKey => configuration?.masterKey;

  /// Return [Parse] application ID
  String? get applicationId => configuration?.applicationId;

  /// Return [Parse] server path
  String? get server => configuration?.uri.toString();

  /// Return [Parse] logging status
  bool get enableLogging => configuration?.enableLogging ?? false;

  /// Return [Parse] initialized status
  bool get initialized => configuration != null;

  Platform? _platform;

  /// Convert [BaseRequest] object into friendly formatted CURL command into console log
  void logToCURL(BaseRequest request) => client.logToCURL(request);

  @visibleForTesting
  set platform(Platform platform) {
    _platform = platform;
  }

  Platform get platform => _platform ?? kDefaultPlatform;
}

/// The [ParseConfiguration] class contains variable that handle global
/// configuration for the Parse library.
class ParseConfiguration {
  ParseConfiguration({
    required String server,
    required this.applicationId,
    this.liveQueryServer,
    this.clientKey,
    this.masterKey,
    this.enableLogging = false,
    this.httpClient,
  })  : assert(
          server.startsWith('https://') || server.startsWith('http://'),
          'Invalid parse server',
        ),
        assert(
          liveQueryServer == null ||
              liveQueryServer.startsWith('wss://') ||
              liveQueryServer.startsWith('ws://'),
          'Invalid parse live query server',
        ),
        uri = Uri.parse((server.endsWith("/")
            ? server.substring(0, server.length - 1)
            : server));

  /// The [Uri] object parsed from `server`
  final Uri uri;

  /// The live query server
  final String? liveQueryServer;

  /// The application ID of Parse Server
  final String applicationId;

  /// The client key of Parse Server
  final String? clientKey;

  /// The master key of Parse Server
  final String? masterKey;

  /// Enable show every request sent to Parse Server into CURL format
  final bool enableLogging;

  /// Add your custom [BaseClient] class to intercept Parse request here.
  final BaseClient? httpClient;
}
