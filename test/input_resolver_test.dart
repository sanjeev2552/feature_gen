import 'dart:io';

import 'package:feature_gen_cli/input_resolver.dart';
import 'package:test/test.dart';

import 'support/test_fakes.dart';

void main() {
  group('InputResolver', () {
    test('extracts name and resolves schema path relative to input file', () {
      final tempDir = Directory.systemTemp.createTempSync('feature_gen_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final inputDir = Directory('${tempDir.path}/feature')..createSync(recursive: true);
      final inputFile = File('${inputDir.path}/user.dart')
        ..writeAsStringSync('''
@FeatureGenCli(
  name: "user",
  schema: "schemas/user.json",
)
class UserFeature {}
''');

      final resolver = InputResolver(commandHelper: TestCommandHelper());
      final result = resolver.resolve(inputFile.path);

      expect(result.featureName, 'user');
      expect(result.schemaPath, '${inputDir.path}/schemas/user.json');
    });
  });
}
