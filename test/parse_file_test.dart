import 'package:flutter_parse/flutter_parse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Check file name and url must be equal', () {
    final file = ParseFile.fromJson({
      "__type": "File",
      "name": "mount-semeru-1.jpg",
      "url": "https://mount.semeru.com/photo1.jpg"
    });
    expect(file.name == 'mount-semeru-1.jpg', isTrue);
    expect(file.url == 'https://mount.semeru.com/photo1.jpg', isTrue);
  });
}
