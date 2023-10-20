import 'dart:typed_data';

typedef ScpiReplyParser = ScpiReply? Function(Uint8List settings);

class ScpiReply {
  final String name;

  final bool ok;

  final List<String> args;

  const ScpiReply({
    required this.name,
    required this.ok,
    required this.args,
  });
}
