import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:le_test/models.dart';

final _exp = RegExp(
  r'^([^ ]+),(OK|ERROR)(?:,([\w\W]+)?)?$',
  caseSensitive: false,
);

class ScpiReplyTransformer extends StreamTransformerBase<Uint8List, ScpiReply> {
  const ScpiReplyTransformer();

  @override
  Stream<ScpiReply> bind(Stream<Uint8List> stream) {
    return Stream.eventTransformed(
      stream,
      (sink) => _ScpiSink(sink),
    );
  }
}

class _ScpiSink implements EventSink<Uint8List> {
  final EventSink<ScpiReply> _sink;
  final _carry = <int>[];

  _ScpiSink(this._sink);

  @override
  void add(Uint8List chunk) {
    try {
      final input = utf8.decode(chunk);
      // log('received: $input');
      final match = _exp.firstMatch(input);
      if (match == null) {
        throw ArgumentError('Match scpi reply failed: $input');
      }
      final name = match[1]!;
      final ok = match[2]!.toUpperCase() == 'OK';
      final args = match[3]?.split(',') ?? [];
      final reply = ScpiReply(
        name: name,
        ok: ok,
        args: args,
      );
      _sink.add(reply);
    } catch (e) {
      log('$e');
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _sink.addError(error, stackTrace);
  }

  @override
  void close() {
    _carry.clear();
    _sink.close();
  }
}
