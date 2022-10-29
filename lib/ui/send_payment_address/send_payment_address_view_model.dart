import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/utils.dart';

class SendPaymentAddressViewModel extends ChangeNotifier {
  var confirmed = false;
  var textController = TextEditingController();

  late String address;

  void initialise(BuildContext context, String recipientAddress) {
    textController.addListener(validateAddress);
    // replace default amount if previously set.
    if (recipientAddress.isNotEmpty) {
      textController.text = recipientAddress;
    }
    notifyListeners();
  }

  void getClipboard() async {
    var data = await Clipboard.getData('text/plain');
    textController.text = data!.text!;
  }

  void validateAddress() {
    address = textController.text;
    if (textController.text.isNotEmpty) {
      confirmed = isValidAddress(address);
      notifyListeners();
    }
  }
}
