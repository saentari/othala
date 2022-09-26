import 'package:flutter_test/flutter_test.dart';
import 'package:othala/services/bitcoin_client.dart';

void main() {
  group('transaction fees', () {
    BitcoinClient client = BitcoinClient('');

    test('get fee estimate', () async {
      Map fees = await client.getFees();
      expect(fees['type'], 'kilobyte');
      expect(fees['average'], greaterThan(0));
    });
  });
}
