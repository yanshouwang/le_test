import 'package:flutter_test/flutter_test.dart';
import 'package:le_test/util.dart';

void main() {
  test(
    '正确格式化 MAC 地址',
    () {
      const value = '00110aa0ffee';
      final actual = StringFormatter.formatMAC(value);
      const matcher = '00:11:0A:A0:FF:EE';
      expect(actual, matcher);
    },
  );
}
