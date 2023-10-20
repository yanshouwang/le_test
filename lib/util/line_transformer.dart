import 'dart:async';
import 'dart:typed_data';

class LineTransformer extends StreamTransformerBase<Uint8List, Uint8List> {
  const LineTransformer();

  @override
  Stream<Uint8List> bind(Stream<Uint8List> stream) {
    return Stream.eventTransformed(
      stream,
      (sink) => _LinkSink(sink),
    );
  }
}

class _LinkSink implements EventSink<Uint8List> {
  final EventSink<Uint8List> _sink;
  final _carry = <int>[];

  _LinkSink(this._sink);

  @override
  void add(Uint8List chunk) {
    // final text = hex.encode(chunk);
    // log('received chunk: $text');
    _carry.addAll(chunk);
    var start = 0;
    for (var i = 0; i < _carry.length; i++) {
      final code = _carry[i];
      if (code != 0x0d && code != 0x0a && code != 0x00) {
        continue;
      }
      final items = _carry.sublist(start, i);
      start = i + 1;
      if (items.isEmpty) {
        continue;
      }
      final value = Uint8List.fromList(items);
      _sink.add(value);
    }
    _carry.removeRange(0, start);
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
