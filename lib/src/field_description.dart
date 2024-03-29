import 'package:code_builder/code_builder.dart';

class FieldDescription {
  FieldDescription._({
    required this.name,
    required this.type,
    required this.value,
  });

  factory FieldDescription.parse(String name, Map parameters) {
    if (!parameters.containsKey('value')) {
      throw Exception('required parameter "value" not found for field "$name"');
    }

    final params = {}..addAll(parameters);
    if (!params.containsKey('type')) params['type'] = 'String';

    return FieldDescription._(
      name: name,
      type: params['type'] as String,
      value: _buildCode(params),
    );
  }

  final String name;
  final String type;
  final Code value;

  static Code _buildCode(Map<dynamic, dynamic> parameters) {
    if (parameters['type'] == 'String') return Code('"${parameters['value']}"');
    if (parameters['type'] == int) return Code('${parameters['value']}');
    return Code('${parameters['type']}(${parameters['value']})');
  }
}
