import 'package:flutter_test/flutter_test.dart';
import 'package:othala/enums/input_type.dart';
import 'package:othala/utils/utils.dart';

void main() {
  group('mnemonic phrase', () {
    const validPhrase =
        'head merit dutch minor entry dynamic upgrade thing alley fuel owner split';
    const validForeignPhrase =
        'rocheux morceau pilote phrase galaxie survie défensif fusion aimable primitif diminuer biotype';
    const invalidPhrase =
        'head merit dutch minor entry dynamic upgrade thing alley fuel owner';

    test('valid mnemonic phrase', () {
      InputType? res = getInputType(validPhrase);
      expect(res, InputType.mnemonic);
    });

    test('valid french mnemonic phrase', () {
      InputType? res = getInputType(validForeignPhrase, language: 'french');
      expect(res, InputType.mnemonic);
    });

    test('invalid mnemonic phrase', () {
      InputType? res = getInputType(invalidPhrase);
      expect(res, null);
    });
  });

  group('address', () {
    const validAddress = 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4';
    const validTestnetAddress = 'tb1qll5ydhss3adlu4jyr3gewlm8nkdrcfhhumvgq9';
    const invalidAddress = 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t';

    test('valid address', () {
      InputType? res = getInputType(validAddress);
      expect(res, InputType.address);
    });

    test('valid testnet address', () {
      InputType? res = getInputType(validTestnetAddress);
      expect(res, InputType.address);
    });

    test('invalid address', () {
      InputType? res = getInputType(invalidAddress);
      expect(res, null);
    });
  });

  group('lnurl', () {
    const validLnurl =
        'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKKCMM8D9HR7ARPVU7KCMM8D9HZV6E384JNXCF3VSCNSE358QMKZVPK8YENZVMYXUEN2DE4X5CNGWP4VSMX2VE58Q6KYCFNX5UXVDNXX9JKXDENVDSNSCE5XU6XVVR9V56XGCTZS8GQ23';
    const invalidLnurl = 'InvalidLightingUrlString';

    test('valid LNURL', () {
      InputType? res = getInputType(validLnurl);
      expect(res, InputType.lnurl);
    });

    test('invalid LNURL', () {
      InputType? res = getInputType(invalidLnurl);
      expect(res, null);
    });
  });
}
