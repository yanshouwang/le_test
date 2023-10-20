import 'package:string_scanner/string_scanner.dart';

abstract class StringFormatter {
  static String formatMAC(String value) {
    final scanner = StringScanner(value);
    final w2 = RegExp(
      r'[0-9a-f]{2}',
      caseSensitive: false,
    );
    var macAddress = '';
    for (var i = 0; i < 5; i++) {
      scanner.expect(w2);
      macAddress += '${scanner.lastMatch![0]}:';
    }
    scanner.scan(w2);
    macAddress += '${scanner.lastMatch![0]}';
    scanner.expectDone();
    return macAddress.toUpperCase();
  }
}
