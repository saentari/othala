import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/safe_area.dart';
import 'send_payment_address_view_model.dart';

class SendPaymentAddressView extends StatelessWidget {
  const SendPaymentAddressView(this.recipientAddress, {Key? key})
      : super(key: key);

  final String recipientAddress;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SendPaymentAddressViewModel>.reactive(
      viewModelBuilder: () => SendPaymentAddressViewModel(),
      onModelReady: (viewModel) =>
          viewModel.initialise(context, recipientAddress),
      builder: (context, model, child) => SafeAreaX(
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
                onTap: () => model.confirmed == true
                    ? Navigator.pop(context, model.address)
                    : null,
                child: model.confirmed == true
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
                    'Recipient',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    style: const TextStyle(fontSize: 40.0),
                    controller: model.textController,
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
                    onTap: () => model.getClipboard(),
                    child: const Text(
                      'paste from clipboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: customYellow,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
