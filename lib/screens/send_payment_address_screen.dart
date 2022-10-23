import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class SendPaymentAddressScreen extends StatefulWidget {
  const SendPaymentAddressScreen(this.recipientAddress, {Key? key})
      : super(key: key);

  final String recipientAddress;

  @override
  SendPaymentAddressScreenState createState() =>
      SendPaymentAddressScreenState();
}

class SendPaymentAddressScreenState extends State<SendPaymentAddressScreen> {
  late String _address;
  bool _confirmed = false;

  final _myTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _myTextController.addListener(_validateAddress);
    // replace default amount if previously set.
    if (widget.recipientAddress.isNotEmpty) {
      _myTextController.text = widget.recipientAddress;
    }
  }

  @override
  void dispose() {
    _myTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () =>
                  _confirmed == true ? Navigator.pop(context, _address) : null,
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
              onTap: () => Navigator.pop(context, ''),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Recipient',
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
                  maxLines: 3,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'enter address...',
                  ),
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () => _getClipboard(),
                  child: const Text(
                    'paste from clipboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kYellowColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    _myTextController.text = data!.text!;
  }

  void _validateAddress() {
    _address = _myTextController.text;
    if (_myTextController.text.isNotEmpty) {
      _confirmed = isValidAddress(_address);
      setState(() {});
    }
  }
}
