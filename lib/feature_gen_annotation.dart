/// Annotation used by the CLI to locate feature generation metadata.
///
/// Example:
/// ```
/// @FeatureGenCli(
///   name: 'user',
///   schema: 'path/to/schema.json',
/// )
/// ```
class FeatureGenCli {
  final String name;
  final String schema;

  const FeatureGenCli({required this.name, required this.schema});
}
