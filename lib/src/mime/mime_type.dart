library flutter_parse.mime_type;

part 'mime_db.dart';

Map? _extensions;

/// Get the default extension for a given content type.
String? getExtension(String contentType) {
  if (_contentTypes.containsKey(contentType) &&
      _contentTypes[contentType].containsKey('extensions')) {
    final list = _contentTypes[contentType]['extensions'];
    if (list is List && list.isNotEmpty) {
      return _contentTypes[contentType]['extensions'].first;
    }
  }
  return null;
}

/// Get the content type for a given extension or file path.
String getContentType(String extension) {
  _processDb();
  if (extension.lastIndexOf('.') >= 0) {
    // assume a file name or path
    extension = extension.substring(extension.lastIndexOf('.') + 1);
  }

  return _extensions![extension.toLowerCase()] ?? 'application/octet-stream';
}

/// Lazily process the content types in a map indexed by extension.
void _processDb() {
  if (_extensions == null) {
    _extensions = {};
    _contentTypes.forEach((type, typeInfo) {
      if (typeInfo.containsKey('extensions')) {
        for (String ext in typeInfo['extensions']) {
          _extensions![ext] = type;
        }
      }
    });
  }
}
