import 'dart:io';

import 'package:feature_gen_cli/command_helper.dart';

/// Extracts feature name and schema path from a Dart file annotated with
/// `@FeatureGenCli`.
class InputResolver {
  InputResolver({CommandHelper? commandHelper})
      : _commandHelper = commandHelper ?? CommandHelper();

  final CommandHelper _commandHelper;

  /// Resolves the [inputPath] to a feature name and schema path.
  ///
  /// Relative schema paths are resolved against the input file's directory.
  ({String featureName, String schemaPath}) resolve(String inputPath) {
    final file = File(inputPath);
    if (!file.existsSync()) {
      _commandHelper.error('Input file not found: $inputPath');
    }

    final content = file.readAsStringSync();
    final annotationMatch =
        RegExp(r'@FeatureGenCli\s*\(([\s\S]*?)\)', multiLine: true).firstMatch(content);
    if (annotationMatch == null) {
      _commandHelper.error('No @FeatureGenCli annotation found in $inputPath');
    }

    final args = annotationMatch!.group(1) ?? '';
    final name = _extractNamedArg(args, 'name');
    final schema = _extractNamedArg(args, 'schema');

    if (name == null || name.isEmpty) {
      _commandHelper.error('Feature name is missing in @FeatureGenCli annotation.');
    }
    if (schema == null || schema.isEmpty) {
      _commandHelper.error('Schema path is missing in @FeatureGenCli annotation.');
    }

    final resolvedSchema = _resolveSchemaPath(schema!, inputPath);
    return (featureName: name!, schemaPath: resolvedSchema);
  }

  String? _extractNamedArg(String args, String key) {
    final match = RegExp('$key\\s*:\\s*([\"\'])(.*?)\\1', multiLine: true).firstMatch(args);
    return match?.group(2);
  }

  String _resolveSchemaPath(String schemaPath, String inputPath) {
    final schemaFile = File(schemaPath);
    if (schemaFile.isAbsolute) {
      return schemaFile.path;
    }
    final inputDir = File(inputPath).parent.path;
    return File('$inputDir/$schemaPath').path;
  }
}
