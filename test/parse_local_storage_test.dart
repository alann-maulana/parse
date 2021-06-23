import 'package:flutter_parse/flutter_parse.dart';
import 'package:flutter_parse/src/parse_local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Parse Local Storage', () {
    setUpAll(() {
      final ParseConfiguration _configuration = ParseConfiguration(
        server: 'https://SERVER',
        applicationId: 'APPLICATION_ID',
        clientKey: 'CLIENT_KEY',
        enableLogging: true,
      );
      Parse.initialize(_configuration);
      SharedPreferences.setMockInitialValues({});
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    const String key1 = 'default local storage must be empty';
    test(key1, () async {
      final localStorage = await parseLocalStorage.get(key1);

      expect(localStorage!.isEmpty, isTrue);
    });

    const String key2 = 'adding local storage with an item must not be empty';
    test(key2, () async {
      final localStorage = await parseLocalStorage.get(key2);
      await localStorage!.setItem('first', 1);

      expect(localStorage.isEmpty, isFalse);
      expect(localStorage.getItem('first'), 1);
    });

    const String key3 =
        'remove after adding local storage with an item must be empty';
    test(key3, () async {
      final localStorage = await parseLocalStorage.get(key3);
      await localStorage!.setItem('second', 2);

      expect(localStorage.isEmpty, isFalse);
      expect(localStorage.getItem('second'), 2);

      await localStorage.delete();
      expect(localStorage.isEmpty, isTrue);
    });
  });
}
