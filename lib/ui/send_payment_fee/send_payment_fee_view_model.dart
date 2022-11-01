import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/bitcoin_client.dart';
import '../../services/wallet_manager.dart';

class SendPaymentFeeViewModel extends ChangeNotifier {
  late String userSelectedFee;
  late String userConfirmedFee;
  late BitcoinClient bitcoinClient;

  Map fees = {
    "type": "kilobyte",
    "fastest": '...',
    "fast": '...',
    "average": '...',
  };

  void initialise(
      BuildContext context, walletIndex, String confirmedFeeDescription) {
    userSelectedFee = confirmedFeeDescription;
    userConfirmedFee = confirmedFeeDescription;
    networkFees(walletIndex);
    notifyListeners();
  }

  Future<void> networkFees(int walletIndex) async {
    // Network fees
    var walletManager = WalletManager();
    var seed = await walletManager.getWalletSeed(walletIndex);
    bitcoinClient = BitcoinClient(seed);
    fees = await bitcoinClient.getFees();
    notifyListeners();
  }

  void setUserSelectedFee(String selectedFee) {
    userSelectedFee = selectedFee;
    notifyListeners();
  }
}
