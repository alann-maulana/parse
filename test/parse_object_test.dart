import 'package:flutter_parse/flutter_parse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParseObject variable check after fetch', () {
    final fetch = ParseObject.fromJson(className: 'Fetch', json: {
      "objectId": "jmRXtNVKL8",
      "integer": 1234567890,
      "double": 1.23456789,
      "boolean": true,
      "string": "Jane Doe",
      "geopoint": {"__type": "GeoPoint", "latitude": 45, "longitude": 55},
      "timestamp": {"__type": "Date", "iso": "2018-05-25T06:36:05.911Z"},
      "object": {"number": 12345},
      "array": [123, 456, 789],
      "picture": {
        "__type": "File",
        "name": "15cdeaaefdafa3f43099f4a2a72d25de_wilis.jpg",
        "url":
            "https://parsefiles.back4app.com/YtoxICpUQVRdQT96DUAdkGuk85unFzfuOUomHALP/15cdeaaefdafa3f43099f4a2a72d25de_wilis.jpg"
      },
      "createdAt": "2019-09-03T03:24:57.580Z",
      "updatedAt": "2019-09-03T03:25:27.379Z"
    });

    test('className must be equal', () {
      expect(fetch.className == 'Fetch', isTrue);
    });

    test('objectId must be equal', () {
      expect(fetch.objectId == 'jmRXtNVKL8', isTrue);
    });

    test('createdAt must be equal', () {
      expect(fetch.createdAt == DateTime.tryParse('2019-09-03T03:24:57.580Z'),
          isTrue);
    });

    test('updatedAt must be equal', () {
      expect(fetch.updatedAt == DateTime.tryParse('2019-09-03T03:25:27.379Z'),
          isTrue);
    });

    test('integer must be equal', () {
      expect(fetch.get('integer') is int, isTrue);
      expect(fetch.getInteger('integer') == 1234567890, isTrue);
    });

    test('double must be equal', () {
      expect(fetch.get('double') is double, isTrue);
      expect(fetch.getDouble('double') == 1.23456789, isTrue);
    });

    test('boolean must be equal', () {
      expect(fetch.get('boolean') is bool, isTrue);
      expect(fetch.getBoolean('boolean'), isTrue);
    });

    test('string must be equal', () {
      expect(fetch.get('string') is String, isTrue);
      expect(fetch.getString('string') == 'Jane Doe', isTrue);
    });

    test('geopoint must be equal', () {
      expect(fetch.get('geopoint') is ParseGeoPoint, isTrue);
      expect(
          fetch.getParseGeoPoint('geopoint') ==
              ParseGeoPoint(latitude: 45, longitude: 55),
          isTrue);
    });

    test('timestamp must be equal', () {
      expect(fetch.get('timestamp') is DateTime, isTrue);
      expect(
          fetch.getDateTime('timestamp') ==
              DateTime.tryParse('2018-05-25T06:36:05.911Z'),
          isTrue);
    });

    test('object must be equal', () {
      expect(fetch.get('object') is Map, isTrue);
      expect(fetch.getMap('object')?.containsKey('number'), isTrue);
      expect(fetch.getMap('object')?['number'] == 12345, isTrue);
    });

    test('array must be equal', () {
      expect(fetch.get('array') is List, isTrue);
      expect(fetch.getList<int>('array')?.length == 3, isTrue);
      expect(fetch.getList<int>('array')?[1] == 123, isFalse);
    });

    test('file must be equal', () {
      expect(fetch.get('picture') is ParseFile, isTrue);
      expect(
          fetch.getParseFile('picture') ==
              ParseFile.fromJson({
                "__type": "File",
                "name": "15cdeaaefdafa3f43099f4a2a72d25de_wilis.jpg",
                "url":
                    "https://parsefiles.back4app.com/YtoxICpUQVRdQT96DUAdkGuk85unFzfuOUomHALP/15cdeaaefdafa3f43099f4a2a72d25de_wilis.jpg"
              }),
          isTrue);
      expect(
          fetch.getParseFile('picture')?.name ==
              '15cdeaaefdafa3f43099f4a2a72d25de_wilis.jpg',
          isTrue);
      expect(
          fetch.getParseFile('picture')?.url ==
              'https://parsefiles.back4app.com/YtoxICpUQVRdQT96DUAdkGuk85unFzfuOUomHALP/15cdeaaefdafa3f43099f4a2a72d25de_wilis.jpg',
          isTrue);
    });
  });

  group('ParseObject variable check after create', () {
    final create = ParseObject(className: 'Create')
      ..set("integer", 1234567890)
      ..set('boolean', true)
      ..set('string', 'Jane Doe');

    test('className must be equal', () {
      expect(create.className == 'Create', isTrue);
    });

    test('objectId must be null', () {
      expect(create.objectId == null, isTrue);
    });

    test('createdAt must be null', () {
      expect(create.createdAt == null, isTrue);
    });
  });

  group('ParseObject variable check after save', () {
    final saved = ParseObject(className: 'Saved');

    // simulate object has been saved, and get response from server
    final responseJson = {
      "objectId": "jmRXtNVKL8",
      "createdAt": "2019-09-03T03:24:57.580Z"
    };
    saved.mergeJson(responseJson);

    test('className must be equal', () {
      expect(saved.className == 'Saved', isTrue);
    });

    test('objectId must not be null', () {
      expect(saved.objectId != null, isTrue);
    });

    test('createdAt must not be null', () {
      expect(saved.createdAt != null, isTrue);
    });

    test('updatedAt must not be null', () {
      expect(saved.updatedAt != null, isTrue);
    });

    test('updatedAt must equal to createdAt', () {
      expect(saved.updatedAt == saved.createdAt, isTrue);
    });
  });

  group('ParseObject variable change', () {
    final dummy = ParseObject.fromJson(className: 'Dummy', json: {
      "objectId": "jmRXtNVKL8",
      "boolean": true,
      "createdAt": "2019-09-03T03:24:57.580Z",
      "updatedAt": "2019-09-03T03:25:27.379Z"
    });

    test('bool value must be true', () {
      expect(dummy.getBoolean('boolean'), isTrue);
    });

    test('bool value must be false', () {
      dummy.set('boolean', false);
      expect(dummy.getBoolean('boolean'), isFalse);
    });
  });

  group('ParseObject variable remove', () {
    final dummy = ParseObject.fromJson(className: 'Dummy', json: {
      "objectId": "jmRXtNVKL8",
      "integer": 1234567890,
      "createdAt": "2019-09-03T03:24:57.580Z",
      "updatedAt": "2019-09-03T03:25:27.379Z"
    });

    test('integer must not be null', () {
      expect(dummy.get('integer') != null, isTrue);
    });

    test('integer must be null', () {
      dummy.remove('integer');
      expect(dummy.get('integer') != null, isFalse);
    });
  });
}
