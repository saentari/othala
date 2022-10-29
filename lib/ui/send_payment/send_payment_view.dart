import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/safe_area.dart';
import 'send_payment_view_model.dart';

class SendPaymentView extends StatelessWidget {
  const SendPaymentView(this.walletIndex, {Key? key}) : super(key: key);

  final int walletIndex;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SendPaymentViewModel>.reactive(
      viewModelBuilder: () => SendPaymentViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context, walletIndex),
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
                onTap: () =>
                    model.confirmed == true ? model.sendPayment(context) : null,
                child: model.confirmed == true
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
                  onTap: () => model.navigateAndDisplayAddress(context),
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
                          model.recipientAddress.isNotEmpty
                              ? model.recipientAddress
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
                  onTap: () => model.navigateAndDisplayAmount(context),
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
                          model.recipientAmount.isNotEmpty
                              ? '${model.recipientAmount} ${model.unit}'
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
      ),
    );
  }
}
