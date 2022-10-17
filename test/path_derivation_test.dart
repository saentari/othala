import 'package:flutter_test/flutter_test.dart';
import 'package:othala/models/derivation_path.dart';

void main() {
  group('derivation path', () {
    DerivationPath path = DerivationPath();

    test('get purpose', () async {
      final res = path.getPurpose("m/49'/1'/0'/0");
      expect(res, 49);
    });
    test('get coinType', () async {
      final res = path.getCoinType("m/49'/1'/0'/0");
      expect(res, 1);
    });
    test('get account', () async {
      final res = path.getAccount("m/49'/1'/0'/0");
      expect(res, 0);
    });
    test('get change', () async {
      final res = path.getChange("m/49'/1'/0'/0");
      expect(res, 0);
    });
    test('get default addressIndex', () async {
      final res = path.getAddressIndex("m/49'/1'/0'/0");
      expect(res, 0);
    });
    test('get addressIndex', () async {
      final res = path.getAddressIndex("m/49'/1'/0'/0/5");
      expect(res, 5);
    });
  });
}
