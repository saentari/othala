import 'dart:convert';

import 'network_helper.dart';

class ExchangeManager {
  final NetworkHelper _networkHelper = NetworkHelper();

  /// Retrieve bitcoin price
  Future<double> getPrice(String fiatCurrency) async {
    String uri =
        'https://api.coinpaprika.com/v1/tickers/btc-bitcoin?quotes=$fiatCurrency';
    String _responseBody = await _networkHelper.getData(uri);
    double _price = jsonDecode(_responseBody)['quotes'][fiatCurrency]['price'];
    return _price;
  }
}
