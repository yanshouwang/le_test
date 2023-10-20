import 'dart:io';

class CSV {
  final String path;

  CSV(this.path);

  Future<void> write(List<String> items) async {
    final csv = await File(path).create(recursive: true);
    final contents = items.join(',');
    await csv.writeAsString(
      '$contents${Platform.lineTerminator}',
      mode: FileMode.writeOnlyAppend,
      flush: true,
    );
  }
}
