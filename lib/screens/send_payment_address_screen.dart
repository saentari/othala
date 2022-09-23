import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';

class SendPaymentAddressScreen extends StatefulWidget {
  const SendPaymentAddressScreen(this.recipientAddress, {Key? key})
      : super(key: key);

  final String recipientAddress;

  @override
  _SendPaymentAddressScreenState createState() =>
      _SendPaymentAddressScreenState();
}

class _SendPaymentAddressScreenState extends State<SendPaymentAddressScreen> {
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
    return SafeArea(
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
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _confirmed == true
                          ? Navigator.pop(context, _address)
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
