/// Case-conversion utilities for code generation.
///
/// These helpers are intentionally small and predictable, aimed at
/// transforming snake/camel case identifiers used in templates.
extension StringExtension on String {
  /// Converts `snake_case` → `PascalCase`.
  String toPascalCase() {
    return split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join();
  }

  /// Converts `snake_case` → `camelCase`.
  String toCamelCase() {
    final words = split('_');

    return words.first.toLowerCase() +
        words.skip(1).map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join();
  }

  /// Normalises to strict lower `snake_case`.
  String toSnakeCase() {
    return split('_').map((word) => word.toLowerCase()).join('_');
  }

  /// Converts `camelCase` → `snake_case`.
  String camelCaseToSnakeCase() {
    return replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]}_${match[2]}',
    ).toLowerCase();
  }

  /// Converts `camelCase` → `PascalCase`.
  String camelCaseToPascalCase() {
    return replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]}_${match[2]}',
    ).toPascalCase();
  }
}
