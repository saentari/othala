import 'package:bitcoin_dart/bitcoin_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:othala/enums/input_type.dart';
import 'package:othala/services/bitcoin_client.dart';
import 'package:othala/utils/utils.dart';

void main() {
  const seed =
      ('praise you muffin lion enable neck grocery crumble super myself license ghost');

  group('mnemonic phrase', () {
    BitcoinClient client = BitcoinClient(seed);
    client.setNetwork(testnet);

    test('can generate a testnet SegWit address', () async {
      expect(client.address, 'tb1qdyxry6tza2sflfzlr8w6m65873thva724yjlmw');
      var txs = await client.getTransactions(client.address);
      expect(txs.length, 0);
    });
  });

  group('validate address', () {
    const address = 'tb1qdyxry6tza2sflfzlr8w6m65873thva724yjlmw';

    test('valid address', () {
      InputType? res = getInputType(address);
      expect(res, InputType.address);
    });
  });

  group('HD wallet', () {
    BitcoinClient client = BitcoinClient(seed);

    test('BIP44 - Multi-account hierarchy for deterministic wallets', () {
      client.setPurpose(44);
      var address = client.getAddress(0);
      expect(address, '1PLDRLacEkAaaiWnfojVDb5hWpwXvKJrRa');
    });

    test('BIP49 - Derivation scheme for P2WPKH-nested-in-P2SH based accounts',
        () {
      client.setPurpose(49);
      var address = client.getAddress(0);
      expect(address, '3GU5e9mPrLgPemhawVHHrDt6bjZZ6M9CPc');
    });

    test('BIP84 - Derivation scheme for P2WPKH based accounts', () {
      client.setPurpose(84);
      var address = client.getAddress(0);
      expect(address, 'bc1qpeeu3vjrm9dn2y42sl926374y5cvdhfn5k7kxm');
    });

    test('BIP84 - Second index for P2WPKH based account', () {
      var address = client.getAddress(1);
      expect(address, 'bc1qcp7yv3w3kvlqgtsc0867nenl6f0vma3zr6vdun');
    });
  });
}
