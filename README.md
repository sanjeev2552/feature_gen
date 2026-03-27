# Feature Gen

[![pub package](https://img.shields.io/pub/v/feature_gen_cli.svg)](https://pub.dev/packages/feature_gen_cli) [![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![pub points](https://img.shields.io/pub/points/feature_gen_cli)](https://pub.dev/packages/feature_gen_cli/score)

Feature Gen is a Dart CLI that scaffolds clean-architecture feature modules for Flutter projects from a JSON schema.

## Quick Start

**Requirements:** Dart SDK `>=3.10.4`, a Flutter project with a valid `pubspec.yaml`, and `dart` on your PATH. Run the CLI from the Flutter project root so `pubspec.yaml` resolution works.

```bash
# 1. Install
dart pub global activate feature_gen_cli

# 2. Run
feature_gen_cli <feature_name> <schema.json>
# Example: feature_gen_cli user example/user_schema.json

# Overwrite existing generated files (optional)
feature_gen_cli <feature_name> <schema.json> --overwrite
```

Feature names should be lowercase `snake_case` (the generated folder is `lib/features/<feature_name>/`).

### CLI Options

```bash
feature_gen_cli <feature_name> <schema.json> -o   # overwrite existing generated files
feature_gen_cli --version                          # print package version
feature_gen_cli --help                             # show help
```

## Schema Reference

The schema is a single JSON file requiring three sections: `config`, `api.methods`, and `response`.

```json
{
  "config": { "bloc": true, "riverpod": false },
  "api": { 
    "methods": { 
      "getUser": {},
      "updateUser": { "body": { "name": "string", "email": "string" } },
      "deleteUser": { "params": { "id": "int" } }
    } 
  },
  "response": { "id": "int", "name": "string" }
}
```

- **`config`**: Both keys (`bloc` and `riverpod`) are required; exactly one must be `true`.
- **`api.methods`**: Define endpoints (camelCase). Optionally include `params`, `body`, or `query` to generate `UseCase` and param classes.
- **`response`**: Define base entity/model fields. Wrap in an array for lists (e.g., `[ { "id": "int" } ]`). Supports primitives (`"string"`, `"int"`, `"double"`, `"bool"`, `"list"`, `"map"`) and nested objects.

## Generated Structure

Running the CLI produces a complete clean-architecture module in `lib/features/<feature_name>/` containing:
- **data/**: Datasources, models, and repository implementations.
- **domain/**: Entities, repository interfaces, and usecases.
- **presentation/**: BLoC/Notifier and screens.

The CLI automatically adds missing dependencies, runs `build_runner`, and formats the generated code.

## Overwrite Behavior

By default, the CLI only generates missing files and will not overwrite existing files. Use `--overwrite` (or `-o`) to force regeneration.

## Troubleshooting

- **Schema validation errors**: Ensure `config`, `api.methods`, and `response` exist, and that exactly one of `config.bloc` or `config.riverpod` is `true`.
- **`build_runner` failed**: Re-run it manually: `dart run build_runner build -d`.

## Support ❤️

If you find this package helpful, please consider giving it a like on [pub.dev](https://pub.dev/packages/feature_gen_cli) and adding a ⭐ star on [GitHub](https://github.com/sanjeev2552/feature_gen)! Your support is greatly appreciated.

## Contributing

- Install dependencies: `dart pub get`
- Run tests: `dart test`
- Format code: `dart format .`

Note: The test suite is pure unit tests and avoids running external commands.

## License

MIT
