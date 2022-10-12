import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class SendPaymentAmountScreen extends StatefulWidget {
  const SendPaymentAmountScreen(this.recipientAmount, this.maxBalance,
      {Key? key})
      : super(key: key);

  final String recipientAmount;
  final num maxBalance;

  @override
  SendPaymentAmountScreenState createState() => SendPaymentAmountScreenState();
}

class SendPaymentAmountScreenState extends State<SendPaymentAmountScreen> {
  late String _amount;
  bool _confirmed = false;

  final _myTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _myTextController.addListener(_validateAmount);
    // replace default amount if previously set.
    if (widget.recipientAmount.isNotEmpty) {
      _myTextController.text = widget.recipientAmount;
    }
  }

  @override
  void dispose() {
    _myTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkBackgroundColor,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.only(
              bottom: 16.0,
              left: 8.0,
              right: 8.0,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    color: kYellowColor,
                    height: 40.0,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        style: const TextStyle(fontSize: 40.0),
                        controller: _myTextController,
                        textAlign: TextAlign.center,
                        minLines: 1,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration.collapsed(
                          hintText: '0.0 btc',
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _confirmed == true
                            ? Navigator.pop(context, _amount)
                            : null,
                        child: _confirmed == true
                            ? const CustomFlatButton(
                                textLabel: 'Confirm',
                              )
                            : const CustomFlatButton(
                                textLabel: 'Confirm',
                                enabled: false,
                              ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context, '');
                        },
                        child: const CustomFlatButton(
                          textLabel: 'Cancel',
                          buttonColor: kDarkBackgroundColor,
                          fontColor: kWhiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateAmount() {
    if (_myTextController.text.isNotEmpty) {
      double inputAmount = double.parse(_myTextController.text);
      if (inputAmount <= widget.maxBalance && inputAmount > 0) {
        _amount = _myTextController.text;
        _confirmed = true;
      } else {
        _confirmed = false;
      }
    } else {
      _confirmed = false;
    }
    setState(() {});
  }
}
