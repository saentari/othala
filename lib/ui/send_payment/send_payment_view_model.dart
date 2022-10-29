import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../enums/bitcoin_unit_enum.dart';
import '../../models/address.dart';
import '../../models/wallet.dart';
import '../send_payment_address/send_payment_address_view.dart';
import '../send_payment_amount/send_payment_amount_view.dart';

class SendPaymentViewModel extends ChangeNotifier {
  // TODO: implement TransactionBuilder.

  // var recipientAddress = '';
  // var recipientAmount = '';
  // TODO: replace temporary values for testing the IXD flow.
  var recipientAddress = 'tb1q669kqq0ykrzgx337w3sj0kdf6zcuznvff34z85';
  var recipientAmount = '0.0001';
  var unit = BitcoinUnit.btc.toShortString();
  var confirmed = false;
  late Wallet wallet;

  void initialise(BuildContext context, int walletIndex) {
    final box = Hive.box('walletBox');
    if (walletIndex < box.length) {
      wallet = box.getAt(walletIndex);
    }
    if (recipientAddress.isNotEmpty && recipientAmount.isNotEmpty) {
      confirmed = true;
    }
    notifyListeners();
  }

  Future<void> navigateAndDisplayAddress(BuildContext context) async {
    recipientAddress = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) => SendPaymentAddressView(recipientAddress)),
    );
    notifyListeners();
  }

  Future<void> navigateAndDisplayAmount(BuildContext context) async {
    num maxBalance = 0;
    for (Address addressObj in wallet.addresses) {
      maxBalance = maxBalance + addressObj.balance;
    }
    recipientAmount = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) =>
              SendPaymentAmountView(recipientAmount, maxBalance)),
    );
    notifyListeners();
  }

  sendPayment(BuildContext context) {
    Navigator.pushReplacementNamed(
        context, '/send_payment_confirmation_screen');
  }
}
