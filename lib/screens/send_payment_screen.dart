import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../enums/bitcoin_unit_enum.dart';
import '../models/address.dart';
import '../models/wallet.dart';
import '../screens/send_payment_address_screen.dart';
import '../screens/send_payment_amount_screen.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class SendPaymentScreen extends StatefulWidget {
  const SendPaymentScreen(this.walletIndex, {Key? key}) : super(key: key);

  final int walletIndex;

  @override
  SendPaymentScreenState createState() => SendPaymentScreenState();
}

class SendPaymentScreenState extends State<SendPaymentScreen> {
  // TODO: implement TransactionBuilder.

  // var recipientAddress = '';
  // var recipientAmount = '';
  // TODO: replace temporary values for testing the IXD flow.
  var recipientAddress = 'tb1q669kqq0ykrzgx337w3sj0kdf6zcuznvff34z85';
  var recipientAmount = '0.0001';
  var unit = BitcoinUnit.btc.toShortString();
  var confirmed = false;
  late Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('walletBox').listenable(),
        builder: (context, Box box, widget2) {
          if (widget.walletIndex < box.length) {
            wallet = box.getAt(widget.walletIndex);
          }
          if (recipientAddress.isNotEmpty && recipientAmount.isNotEmpty) {
            confirmed = true;
          }
          return SafeAreaX(
            appBar: AppBar(
              centerTitle: true,
              title: titleIcon,
              backgroundColor: customBlack,
              automaticallyImplyLeading: false,
            ),
            bottomBar: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => confirmed == true ? sendPayment() : null,
                    child: confirmed == true
                        ? const CustomFlatButton(
                            textLabel: 'Send',
                          )
                        : const CustomFlatButton(
                            textLabel: 'Send',
                            enabled: false,
                          ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CustomFlatButton(
                      textLabel: 'Cancel',
                      buttonColor: customDarkBackground,
                      fontColor: customWhite,
                    ),
                  ),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        navigateAndDisplayAddress(context);
                      },
                      child: Container(
                        width: double.infinity,
                        color: customTransparent,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recipient',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: customDarkNeutral5,
                              ),
                            ),
                            Text(
                              recipientAddress.isNotEmpty
                                  ? recipientAddress
                                  : 'Enter address...',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        navigateAndDisplayAmount(context);
                      },
                      child: Container(
                        width: double.infinity,
                        color: customTransparent,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: customDarkNeutral5,
                              ),
                            ),
                            Text(
                              recipientAmount.isNotEmpty
                                  ? '$recipientAmount $unit'
                                  : 'Enter amount...',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Future<void> navigateAndDisplayAddress(BuildContext context) async {
    recipientAddress = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) => SendPaymentAddressScreen(recipientAddress)),
    );
    setState(() {});
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
              SendPaymentAmountScreen(recipientAmount, maxBalance)),
    );
    setState(() {});
  }

  sendPayment() {
    Navigator.pushReplacementNamed(
        context, '/send_payment_confirmation_screen');
  }
}
