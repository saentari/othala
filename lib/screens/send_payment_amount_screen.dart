import 'package:flutter/material.dart';

import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

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
  late String amount;
  var confirmed = false;
  var textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.addListener(validateAmount);
    // replace default amount if previously set.
    if (widget.recipientAmount.isNotEmpty) {
      textController.text = widget.recipientAmount;
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () =>
                  confirmed == true ? Navigator.pop(context, amount) : null,
              child: confirmed == true
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
              onTap: () => Navigator.pop(context, ''),
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
                  controller: textController,
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
        ],
      ),
    );
  }

  void validateAmount() {
    if (textController.text.isNotEmpty) {
      var inputAmount = double.parse(textController.text);
      if (inputAmount <= widget.maxBalance && inputAmount > 0) {
        amount = textController.text;
        confirmed = true;
      } else {
        confirmed = false;
      }
    } else {
      confirmed = false;
    }
    setState(() {});
  }
}
