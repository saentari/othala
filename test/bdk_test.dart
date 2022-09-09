import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mnemonic phrase', () {
    test('can generate a mnemonic phrase', () async {
      final words = await bdk.generateMnemonic();
      expect(words.split(' ').length, equals(18));
    });
  });
}
