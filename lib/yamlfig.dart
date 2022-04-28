library yamlfig;

import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:yaml/yaml.dart';

import 'src/field_description.dart';

Builder yamlfigBuilder(_) => YamlFigBuilder();

class YamlFigBuilder extends Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    '.yaml': ['.config.dart']
  };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final yaml =
    loadYaml(await buildStep.readAsString(buildStep.inputId)) as Map;

    for (final requiredParam in ['name', 'fields']) {
      if (!yaml.containsKey(requiredParam)) {
        throw Exception('"$requiredParam" parameter is required');
      }
    }

    final fields = <FieldDescription>[
      for (final name in yaml['fields'].keys.cast<String>().toList()..sort())
        if (yaml['fields'][name] is! Map)
          throw Exception('Non-map entry: $name, ${yaml[name].runtimeType}')
        else
          FieldDescription.parse(name, yaml['fields'][name] as Map)
    ];

    final cls = Class((builder) {
      builder.name = yaml['name'];

      for (final entry in fields) {
        builder.fields.add(
          Field(
                (field) => field
              ..static = true
              ..name = entry.name
              ..type = Reference(entry.type)
              ..assignment = entry.value,
          ),
        );
      }
    });

    final emitter = DartEmitter(allocator: Allocator.simplePrefixing());
    await buildStep.writeAsString(
        buildStep.inputId.changeExtension('.config.dart'),
        DartFormatter().format('${cls.accept(emitter)}'));
  }
}
