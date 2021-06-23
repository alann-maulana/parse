import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../flutter_parse.dart';
import 'mime/mime_type.dart' as mime;
import 'parse_base_object.dart';
import 'parse_http_client.dart';

class ParseFile implements ParseBaseObject {
  ParseFile({
    required String name,
    required Uint8List fileBytes,
    String? fileExtension,
    String? contentType,
  })  : assert(name.isNotEmpty),
        assert(
            fileExtension == null || contentType == null,
            'Cannot provide both a fileExtension and a contentType\n'
            'The fileExtension argument is just a shorthand for "contentType: mime.getContentType(fileExtension)".'),
        this._name = name,
        this._fileBytes = fileBytes,
        this._contentType = contentType ?? mime.getContentType(fileExtension!);

  @visibleForTesting
  ParseFile.fromJson(dynamic json) {
    _mergeFrom(json);
  }

  _mergeFrom(dynamic json) {
    _url = json['url'];
    _name = json['name'];
  }

  late String _name;
  Uint8List? _fileBytes;
  String? _contentType;
  String? _url;

  String get name => _name;

  String? get url => _url;

  bool get saved => url != null;

  @override
  String get path {
    assert(parse.configuration != null);
    return '${parse.configuration!.uri.path}/files/$_name';
  }

  @override
  get asMap {
    final map = <String, String>{
      '__type': 'File',
      'name': _name,
    };

    if (saved) {
      map['url'] = _url!;
    }

    return map;
  }

  @override
  String toString() => json.encode(asMap);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParseFile &&
          runtimeType == other.runtimeType &&
          _name == other._name &&
          _url == other._url;

  @override
  int get hashCode => _name.hashCode ^ _url.hashCode;

  Future<ParseFile> upload() async {
    if (saved) {
      return Future.value(this);
    }

    final headers = <String, String>{'Content-Type': _contentType!};

    final response = await parseHTTPClient.post(
      path,
      headers: headers,
      body: _fileBytes,
    );

    _mergeFrom(response);
    return this;
  }
}
