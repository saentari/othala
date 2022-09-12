import 'package:bitcoin_dart/bitcoin_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:othala/enums/input_type.dart';
import 'package:othala/services/bitcoin_client.dart';
import 'package:othala/utils/utils.dart';

void main() {
  group('mnemonic phrase', () {
    const seed =
        ('praise you muffin lion enable neck grocery crumble super myself license ghost');

    BitcoinClient client = BitcoinClient(seed);
    client.setNetwork(testnet);

    test('can generate a testnet SegWit address', () async {
      expect(client.address, 'tb1qdyxry6tza2sflfzlr8w6m65873thva724yjlmw');
      var txs = await client.getTransactions(client.address);
      expect(txs.length, 0);
    });
  });

  group('address', () {
    const address = 'tb1qdyxry6tza2sflfzlr8w6m65873thva724yjlmw';

    test('valid address', () {
      InputType? res = getInputType(address);
      expect(res, InputType.address);
    });
  });
}
