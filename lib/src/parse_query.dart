import 'dart:async';
import 'dart:convert';

import '../flutter_parse.dart';
import 'parse_encoder.dart';
import 'parse_exception.dart';
import 'parse_geo_point.dart';
import 'parse_http_client.dart';
import 'parse_object.dart';
import 'parse_user.dart';

class ParseQuery<T extends ParseObject> {
  final String className;
  final List<String> _includes = [];
  final List<String> _order = [];
  final Map<String, dynamic> _where = Map();
  List<String>? _selectedKeys;
  int _limit = -1;
  int _skip = 0;
  bool _countEnabled = false;

  ParseQuery({required this.className});

  ParseQuery get copy {
    final newQuery = ParseQuery(className: className);
    newQuery._includes.addAll(_includes);
    newQuery._order.addAll(_order);
    newQuery._where.addAll(_where);
    newQuery._selectedKeys = _selectedKeys;
    newQuery._limit = _limit;
    newQuery._skip = _skip;
    newQuery._countEnabled = _countEnabled;

    return newQuery;
  }

  void _addCondition(String key, String condition, dynamic value) {
    Map<String, dynamic>? whereValue;

    // Check if we already have some of a condition
    if (_where.containsKey(key)) {
      dynamic existingValue = _where[key];
      if (existingValue is Map<String, dynamic>) {
        whereValue = existingValue;
      }
    }

    whereValue ??= {};

    whereValue.putIfAbsent(condition, () => value);

    _where.putIfAbsent(key, () => whereValue);
  }

  void whereEqualTo(String key, dynamic value) {
    _where.putIfAbsent(key, () => parseEncoder.encode(value));
  }

  void whereLessThan(String key, dynamic value) {
    _addCondition(key, "\$lt", value);
  }

  void whereNotEqualTo(String key, dynamic value) {
    _addCondition(key, "\$ne", parseEncoder.encode(value));
  }

  void whereGreaterThan(String key, dynamic value) {
    _addCondition(key, "\$gt", value);
  }

  void whereLessThanOrEqualTo(String key, dynamic value) {
    _addCondition(key, "\$lte", value);
  }

  void whereGreaterThanOrEqualTo(String key, dynamic value) {
    _addCondition(key, "\$gte", value);
  }

  void whereContainedIn(String key, List<dynamic> values) {
    _addCondition(key, "\$in", values);
  }

  void whereContainsAll(String key, List<dynamic> values) {
    _addCondition(key, "\$all", values);
  }

  void whereNotContainedIn(String key, List<dynamic> values) {
    _addCondition(key, "\$nin", values);
  }

  void whereMatches(String key, String regex) {
    _addCondition(key, "\$regex", regex);
  }

  void whereMatches2(String key, String regex, String modifiers) {
    _addCondition(key, "\$regex", regex);
    if (modifiers.isNotEmpty) {
      _addCondition(key, "\$options", modifiers);
    }
  }

  void whereContains(String key, String substring,
      {bool caseInsensitive = false}) {
    String regex = RegExp.escape(substring);
    if (caseInsensitive) {
      regex = "${caseInsensitive ? "(?i)" : ""}$regex";
    }
    whereMatches(key, regex);
  }

  void whereStartsWith(String key, String prefix,
      {bool caseInsensitive = false}) {
    String regex = RegExp.escape(prefix);
    regex = "${caseInsensitive ? "(?i)" : ""}^$regex";
    whereMatches(key, regex);
  }

  void whereEndsWith(String key, String suffix,
      {bool caseInsensitive = false}) {
    String regex = RegExp.escape(suffix);
    regex = "${caseInsensitive ? "(?i)" : ""}$regex\$";
    whereMatches(key, regex);
  }

  void whereExists(String key) {
    _addCondition(key, "\$exists", true);
  }

  void whereDoesNotExist(String key) {
    _addCondition(key, "\$exists", false);
  }

  void whereDoesNotMatchKeyInQuery(
      String key, String keyInQuery, ParseQuery query) {
    Map<String, dynamic> condition = Map();
    condition.putIfAbsent("key", () => keyInQuery);
    condition.putIfAbsent("query", () => query);
    _addCondition(key, "\$dontSelect", condition);
  }

  void whereMatchesKeyInQuery(String key, String keyInQuery, ParseQuery query) {
    Map<String, dynamic> condition = Map();
    condition.putIfAbsent("key", () => keyInQuery);
    condition.putIfAbsent("query", () => query);
    _addCondition(key, "\$select", condition);
  }

  void whereDoesNotMatchQuery(String key, ParseQuery query) {
    _addCondition(key, "\$notInQuery", query);
  }

  void whereMatchesQuery(String key, ParseQuery query) {
    _addCondition(key, "\$inQuery", query);
  }

  void whereNear(String key, ParseGeoPoint point) {
    _addCondition(key, "\$nearSphere", point);
  }

  void whereWithinKilometers(String key, ParseGeoPoint point, num maxDistance) {
    Map<String, dynamic> condition = Map();
    condition["\$nearSphere"] = point;
    condition["\$maxDistanceInKilometers"] = maxDistance;
    _where.putIfAbsent(key, () => parseEncoder.encode(condition));
  }

  void maxDistance(String key, double maxDistance) {
    _addCondition(key, "\$maxDistance", maxDistance);
  }

  void whereWithin(
      String key, ParseGeoPoint southwest, ParseGeoPoint northeast) {
    List<dynamic> array = [];
    array.add(southwest);
    array.add(northeast);
    Map<String, List<dynamic>> dictionary = Map();
    dictionary.putIfAbsent("\$box", () => array);
    _addCondition(key, "\$within", dictionary);
  }

  void whereGeoWithin(String key, List<ParseGeoPoint> points) {
    Map<String, List<ParseGeoPoint>> dictionary = Map();
    dictionary.putIfAbsent("\$polygon", () => points);
    _addCondition(key, "\$geoWithin", dictionary);
  }

  void whereGeoIntersects(String key, ParseGeoPoint point) {
    Map<String, ParseGeoPoint> dictionary = Map();
    dictionary.putIfAbsent("\$point", () => point);
    _addCondition(key, "\$geoIntersects", dictionary);
  }

  void setOrder(String key) {
    _order.clear();
    _order.add(key);
  }

  List<String> get order => _order;

  void addOrder(String key) {
    _order.add(key);
  }

  void orderByAscending(String key) {
    setOrder(key);
  }

  void addAscendingOrder(String key) {
    addOrder(key);
  }

  void orderByDescending(String key) {
    setOrder("-$key");
  }

  void addDescendingOrder(String key) {
    addOrder("-$key");
  }

  void include(String key) {
    _includes.add(key);
  }

  List<String> get includes => _includes;

  void selectKeys(List<String> keys) {
    if (_selectedKeys == null) {
      _selectedKeys = [];
    }

    _selectedKeys!.addAll(keys);
  }

  List<String>? get selectedKeys => _selectedKeys;

  void setLimit(int limit) {
    _limit = limit;
  }

  int get limit => _limit;

  void setSkip(int skip) {
    _skip = skip;
  }

  int get skip => _skip;

  Map<String, dynamic> toJson() {
    var params = toJsonParams();
    assert(!params.containsKey("count"));
    params.putIfAbsent("className", () => className);

    return params;
  }

  Map<String, dynamic> toJsonParams() {
    Map<String, dynamic> params = Map();

    if (_where.isNotEmpty) {
      params.putIfAbsent("where", () => parseEncoder.encode(_where));
    }
    if (_limit >= 0) {
      params.putIfAbsent("limit", () => _limit);
    }
    if (_countEnabled) {
      params.putIfAbsent("count", () => 1);
      params.putIfAbsent("limit", () => 0);
    } else {
      if (_skip > 0) {
        params.putIfAbsent("skip", () => _skip);
      }
    }
    if (_order.isNotEmpty) {
      params.putIfAbsent("order", () => _order.join(','));
    }
    if (_includes.isNotEmpty) {
      params.putIfAbsent("include", () => _includes.join(','));
    }
    if (_selectedKeys != null) {
      params.putIfAbsent("keys", () => _selectedKeys!.join(','));
    }

    return params;
  }

  static ParseQuery or(List<ParseQuery> queries) {
    final className = queries[0].className;
    final clauseOr = queries.map((q) {
      if (q.className != className) {
        throw ParseException(
            code: ParseException.invalidClassName,
            message: 'different className');
      }
      return q._where;
    }).toList();
    return ParseQuery(className: className)..whereEqualTo("\$or", clauseOr);
  }

  Future<List<dynamic>> findAsync({bool useMasterKey = false}) async {
    dynamic result = await _find(useMasterKey: useMasterKey);
    if (result.containsKey("results")) {
      List<dynamic> results = result["results"];
      List<dynamic> objects = [];
      results.forEach((json) {
        String objectId = json["objectId"];
        if (className == '_Session') {
          ParseSession session = ParseSession.fromJson(json: json);
          objects.add(session);
        } else if (className == '_Role') {
          ParseRole role = ParseRole.fromMap(json);
          objects.add(role);
        } else if (className == '_User') {
          ParseUser user = ParseUser.fromJson(json: json);
          objects.add(user);
        } else {
          // ignore: invalid_use_of_visible_for_testing_member
          ParseObject object = ParseObject.fromJson(
            className: className,
            objectId: objectId,
            json: json,
          );
          objects.add(object);
        }
      });
      return objects;
    }

    return [];
  }

  Future<dynamic> _find({bool useMasterKey = false}) {
    _countEnabled = false;
    return _query(useMasterKey: useMasterKey);
  }

  Future<int> countAsync({bool useMasterKey = false}) async {
    final result = await _count(useMasterKey: useMasterKey);
    if (result.containsKey("count")) {
      return result["count"];
    }

    return 0;
  }

  Future<dynamic> _count({bool useMasterKey = false}) {
    _countEnabled = true;
    return _query(useMasterKey: useMasterKey);
  }

  Future<dynamic> _query({bool useMasterKey = false}) {
    assert(parse.configuration != null);
    Map<String, dynamic> params = toJsonParams();
    params.putIfAbsent("_method", () => "GET");

    dynamic body = json.encode(params);
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };

    return parseHTTPClient.post(
      '${parse.configuration!.uri.path}/classes/$className',
      useMasterKey: useMasterKey,
      body: body,
      headers: headers,
    );
  }
}
