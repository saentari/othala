import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/safe_area.dart';
import 'send_payment_amount_view_model.dart';

class SendPaymentAmountView extends StatelessWidget {
  const SendPaymentAmountView(this.recipientAmount, this.maxBalance, {Key? key})
      : super(key: key);

  final String recipientAmount;
  final num maxBalance;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SendPaymentAmountViewModel>.reactive(
      viewModelBuilder: () => SendPaymentAmountViewModel(),
      onModelReady: (viewModel) =>
          viewModel.initialise(context, recipientAmount, maxBalance),
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
                    ? Navigator.pop(context, model.amount)
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
                    'Amount',
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
      ),
    );
  }
}
