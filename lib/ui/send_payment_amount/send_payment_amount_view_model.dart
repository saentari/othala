import 'package:flutter/cupertino.dart';

class SendPaymentAmountViewModel extends ChangeNotifier {
  var confirmed = false;
  var textController = TextEditingController();

  late String amount;
  late num maxBalance;

  void initialise(
      BuildContext context, String recipientAmount, num maxBalance) {
    this.maxBalance = maxBalance;
    textController.addListener(validateAmount);
    // replace default amount if previously set.
    if (recipientAmount.isNotEmpty) {
      textController.text = recipientAmount;
    }
    notifyListeners();
  }

  void validateAmount() {
    if (textController.text.isNotEmpty) {
      var inputAmount = double.parse(textController.text);
      if (inputAmount <= maxBalance && inputAmount > 0) {
        amount = textController.text;
        confirmed = true;
      } else {
        confirmed = false;
      }
    } else {
      confirmed = false;
    }
    notifyListeners();
  }
}
