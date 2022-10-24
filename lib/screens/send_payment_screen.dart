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

  bool _confirmed = false;
  // String _recipientAddress = '';
  // String _recipientAmount = '';
  // TODO: replace temporary values for testing the IXD flow.
  String _recipientAddress = 'tb1q669kqq0ykrzgx337w3sj0kdf6zcuznvff34z85';
  String _recipientAmount = '0.0001';
  final String _unit = BitcoinUnit.btc.toShortString();
  late Wallet _wallet;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('walletBox').listenable(),
        builder: (context, Box box, widget2) {
          if (widget.walletIndex < box.length) {
            _wallet = box.getAt(widget.walletIndex);
          }
          if (_recipientAddress.isNotEmpty && _recipientAmount.isNotEmpty) {
            _confirmed = true;
          }
          return SafeAreaX(
            appBar: AppBar(
              centerTitle: true,
              title: titleIcon,
              backgroundColor: kBlackColor,
              automaticallyImplyLeading: false,
            ),
            bottomBar: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _confirmed == true ? _sendPayment() : null,
                    child: _confirmed == true
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
                      buttonColor: kDarkBackgroundColor,
                      fontColor: kWhiteColor,
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
                        _navigateAndDisplayAddress(context);
                      },
                      child: Container(
                        width: double.infinity,
                        color: kTransparentColor,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recipient',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: kDarkNeutral5Color,
                              ),
                            ),
                            Text(
                              _recipientAddress.isNotEmpty
                                  ? _recipientAddress
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
                        _navigateAndDisplayAmount(context);
                      },
                      child: Container(
                        width: double.infinity,
                        color: kTransparentColor,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: kDarkNeutral5Color,
                              ),
                            ),
                            Text(
                              _recipientAmount.isNotEmpty
                                  ? '$_recipientAmount $_unit'
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

  Future<void> _navigateAndDisplayAddress(BuildContext context) async {
    _recipientAddress = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) => SendPaymentAddressScreen(_recipientAddress)),
    );
    setState(() {});
  }

  Future<void> _navigateAndDisplayAmount(BuildContext context) async {
    num maxBalance = 0;
    for (Address addressObj in _wallet.addresses) {
      maxBalance = maxBalance + addressObj.balance;
    }
    _recipientAmount = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) =>
              SendPaymentAmountScreen(_recipientAmount, maxBalance)),
    );
    setState(() {});
  }

  _sendPayment() {
    Navigator.pushReplacementNamed(
        context, '/send_payment_confirmation_screen');
  }
}
