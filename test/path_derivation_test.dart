import 'package:flutter_test/flutter_test.dart';
import 'package:othala/models/derivation_path.dart';

void main() {
  group('derivation path', () {
    final dp = DerivationPath("m/49'/1'/0'/0");

    test('get purpose', () async {
      expect(dp.purpose, 49);
    });
    test('get coinType', () async {
      expect(dp.coinType, 1);
    });
    test('get account', () async {
      expect(dp.account, 0);
    });
    test('get change', () async {
      expect(dp.change, 0);
    });
    test('get addressIndex', () async {
      expect(dp.addressIndex, 0);
    });
    test('set new addressIndex', () async {
      dp.setAddressIndex(5);
      expect(dp.addressIndex, 5);
      expect(dp.derivationPath, "m/49'/1'/0'/0/5");
    });
  });
}
