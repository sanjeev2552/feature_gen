import 'dart:convert';
import 'dart:io';

import 'package:feature_gen/command_helper.dart';
import 'package:feature_gen/string_extension.dart';
import 'package:feature_gen/types.dart';
import 'package:feature_gen/yaml_helper.dart';

/// Parses JSON schema files and builds the template [Context] for code generation.
///
/// The parser is intentionally strict about required sections so generated code
/// is predictable and templates can rely on stable fields.
class Parser {
  /// Reads and deserialises the JSON schema file at [path] into a [Schema].
  Schema parse(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      CommandHelper().error('Schema file not found: $path');
    }
    final json = jsonDecode(file.readAsStringSync());
    return Schema.fromJson(json);
  }

  /// Builds a [Context] from a [featureName] and parsed [schema].
  ///
  /// Returns an empty context if validation fails. The caller is expected to
  /// halt or surface the error to the user.
  Future<Context> buildContext(String featureName, Schema schema) async {
    final projectRoot = Directory.current.path;
    final projectName = await YamlHelper().getProjectName(workingDirectory: projectRoot);

    if (!validateSchema(schema)) {
      return Context(
        name: '',
        nameLowerCase: '',
        nameCamelCase: '',
        fields: [],
        methods: [],
        generateUseCase: false,
        projectRoot: projectRoot,
        projectName: projectName,
      );
    }

    // Use consistent naming across the generated layers.
    final feature = featureName.toPascalCase();
    bool generateUseCase = false;

    final methods = <ContextMethod>[];
    // Build method-level context for usecase/event/bloc generation.
    final apiMethods = schema.api?.methods?.method ?? {};
    for (var method in apiMethods.entries) {
      final contextMethod = buildContextMethod(method);

      methods.add(contextMethod);
      if (contextMethod.hasUseCase) {
        generateUseCase = true;
      }
    }

    // Response fields become entity/model properties.
    final response = schema.response ?? {};
    final fields = response.entries.map((entry) {
      return ContextField(name: entry.key, type: getDartType(entry.value));
    }).toList();

    return Context(
      name: feature,
      nameLowerCase: featureName.toLowerCase(),
      nameCamelCase: featureName.toCamelCase(),
      fields: fields,
      methods: methods,
      generateUseCase: generateUseCase,
      projectRoot: projectRoot,
      projectName: projectName,
    );
  }

  /// Converts an [ApiMethod] schema entry into a [ContextMethod].
  ///
  /// The `hasUseCase` flag is derived from the presence of any params/body/query.
  ContextMethod buildContextMethod(MapEntry<String, ApiMethod> method) {
    final params = buildContextFields(method.value.params ?? {});
    final body = buildContextFields(method.value.body ?? {});
    final query = buildContextFields(method.value.query ?? {});

    return ContextMethod(
      methodName: method.key,
      methodNamePascalCase: method.key.camelCaseToPascalCase(),
      params: params,
      body: body,
      query: query,
      hasParams: params.isNotEmpty,
      hasBody: body.isNotEmpty,
      hasQuery: query.isNotEmpty,
      hasUseCase: params.isNotEmpty || body.isNotEmpty || query.isNotEmpty,
    );
  }

  /// Converts a `{ fieldName: schemaType }` map to a list of [ContextField]s.
  List<ContextField> buildContextFields(Map<String, dynamic> fields) {
    return fields.entries.map((entry) {
      return ContextField(name: entry.key, type: getDartType(entry.value));
    }).toList();
  }

  /// Validates that [schema] has the required `api`, `api.methods`, and `response` sections.
  ///
  /// Validation errors are reported via [CommandHelper] to ensure consistent
  /// CLI output.
  bool validateSchema(Schema schema) {
    if (schema.api == null) {
      CommandHelper().error('Schema is not valid. "api" is required.');
      return false;
    }
    if (schema.api?.methods == null) {
      CommandHelper().error('Schema is not valid. "api.methods" is required.');
      return false;
    }
    if (schema.response == null) {
      CommandHelper().error('Schema is not valid. "response" is required.');
      return false;
    }
    return true;
  }

  /// Maps a schema type (e.g. `"string"`, `"int"`) to its Dart type string.
  ///
  /// This is a simple mapping meant for scaffolding; complex types should be
  /// updated by the developer after generation.
  String getDartType(dynamic type) {
    if (type == 'string' || type is String) {
      return 'String';
    }
    if (type == 'int' || type is int) {
      return 'int';
    }
    if (type == 'double' || type is double) {
      return 'double';
    }
    if (type == 'bool' || type is bool) {
      return 'bool';
    }
    if (type == 'list' || type is List) {
      return 'List<dynamic>';
    }
    if (type == 'map' || type is Map) {
      return 'Map<String, dynamic>';
    }
    return 'dynamic';
  }
}
