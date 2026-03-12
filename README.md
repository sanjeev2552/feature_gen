# Feature Gen

[![pub package](https://img.shields.io/pub/v/feature_gen_cli.svg)](https://pub.dev/packages/feature_gen_cli) [![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![pub points](https://img.shields.io/pub/points/feature_gen_cli)](https://pub.dev/packages/feature_gen_cli/score)

Feature Gen is a Dart CLI that scaffolds clean-architecture feature modules for Flutter projects from a JSON schema.

## Requirements

- Dart SDK `>=3.10.4`
- A Flutter project with a valid `pubspec.yaml`
- `dart` available on your PATH

## Installation

```bash
dart pub global activate feature_gen_cli
```

## Quick Start

1. From your Flutter project root, create a schema file (see `example/user_schema.json`).
2. Run the generator:

```bash
feature_gen_cli user schema.json
```

This creates `lib/features/user/` plus supporting files, installs missing deps, runs `build_runner`, and formats the generated code.

## Usage

```bash
feature_gen_cli <feature_name> <schema.json>
```

### Flags

| Flag              | Description               |
| ----------------- | ------------------------- |
| `-h`, `--help`    | Show usage information    |
| `-v`, `--version` | Print the current version |

### Example

```bash
feature_gen_cli user example/user_schema.json
```

## Schema Reference

The schema is a single JSON file with three required sections: `config`, `api.methods`, and `response`.

### Minimal Schema

```json
{
  "config": { "bloc": true, "riverpod": false },
  "api": { "methods": { "getUser": {} } },
  "response": { "id": "int", "name": "string" }
}
```

### `config`

Exactly one of these must be `true`:

- `bloc` generates BLoC + Event + State.
- `riverpod` generates a Riverpod `Notifier`.

### `api.methods`

Each key is a method name (camelCase). Each method may include any of:

- `params` path parameters
- `body` request body fields
- `query` query parameters

A method that defines at least one of `params`, `body`, or `query` will also get a generated `UseCase` and params classes. Empty methods still generate the repository + datasource wiring.

Example:

```json
{
  "api": {
    "methods": {
      "getUser": {},
      "updateUser": {
        "body": { "name": "string", "email": "string" }
      },
      "deleteUser": {
        "params": { "id": "int" }
      }
    }
  }
}
```

### `response`

Defines the base entity/model fields. Keys are field names; values are types.

List responses are expressed by wrapping the response object in an array:

```json
{ "response": [ { "id": "int", "name": "string" } ] }
```

### Supported Types

| Schema Value | Dart Type              |
| ------------ | ---------------------- |
| `"string"`  | `String`               |
| `"int"`     | `int`                  |
| `"double"`  | `double`               |
| `"bool"`    | `bool`                 |
| `"list"`    | `List<dynamic>`        |
| `"map"`     | `Map<String, dynamic>` |
| `{ ... }`    | Custom model           |
| `[{ ... }]`  | `List<CustomModel>`    |

You can also use literal JSON values (e.g. `123` → `int`, `true` → `bool`). Nested objects and lists of objects are automatically lifted into their own Freezed models/entities based on the field name.

### Naming Conventions

- `feature_name` is expected to be `snake_case` (used for folder names and class conversions).
- Method keys in `api.methods` should be `camelCase` (used to generate class and file names).

## Generated Structure

Running `feature_gen_cli user schema.json` produces:

```
lib/
├── core/
│   └── di/
│       └── injector.dart
└── features/user/
├── data/
│   ├── datasources/
│   │   └── user_remote_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── user_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── user_repository.dart
│   └── usecases/
│       ├── get_user_usecase.dart
│       ├── update_user_usecase.dart
│       └── delete_user_usecase.dart
└── presentation/
    ├── bloc/ (if enabled)
    │   ├── user_bloc.dart
    │   ├── user_event.dart
    │   └── user_state.dart
    ├── riverpod/ (if enabled)
    │   └── user_notifier.dart
    └── screen/
        └── user_screen.dart
```

If any method has params/body/query, a shared base use-case is also created at:

```
lib/features/shared/usecase/base_usecase.dart
```

## What the CLI Changes

- Adds missing dependencies using `dart pub add`.
- Generates files in `lib/features/<feature_name>/` and `lib/core/di/injector.dart`.
- Runs `dart run build_runner build -d`.
- Formats the generated feature directory with `dart format`.
- Overwrites any previously generated files with the same paths.

## Troubleshooting

- **Schema validation errors**: ensure `config`, `api.methods`, and `response` exist, and that exactly one of `config.bloc` or `config.riverpod` is `true`.
- **`build_runner` failed**: re-run it manually in your project root:

```bash
dart run build_runner build -d
```

- **Dependencies not added**: check that you have write access to `pubspec.yaml` and that `dart pub add` succeeds in the same project.

## Project Structure

```
feature_gen/
├── bin/feature_gen_cli.dart        # CLI entry point
├── lib/
│   ├── feature_gen.dart            # Pipeline orchestrator
│   ├── parser.dart                 # JSON schema parser & context builder
│   ├── generator.dart              # Directory creation & template rendering
│   ├── command_runner.dart         # Shell command execution (deps, build, format)
│   ├── command_helper.dart         # Styled console output (errors, success, warnings)
│   ├── types.dart                  # Data models (Schema, Context, etc.)
│   ├── string_extension.dart       # Case-conversion utilities
│   ├── yaml_helper.dart            # pubspec.yaml reader
│   └── template/                   # Mustache template files
└── pubspec.yaml
```

## Contributing

- Install dependencies with `dart pub get`.
- Run tests with `dart test`.
- Keep formatting clean with `dart format .`.

## License

MIT
