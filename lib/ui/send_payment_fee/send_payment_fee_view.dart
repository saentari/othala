import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/safe_area.dart';
import 'send_payment_fee_view_model.dart';

class SendPaymentFeeView extends StatelessWidget {
  const SendPaymentFeeView(this.walletIndex, this.feeDescription, {Key? key})
      : super(key: key);

  final int walletIndex;
  final String feeDescription;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SendPaymentFeeViewModel>.reactive(
      viewModelBuilder: () => SendPaymentFeeViewModel(),
      onModelReady: (viewModel) =>
          viewModel.initialise(context, walletIndex, feeDescription),
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
                  onTap: () => Navigator.pop(context, model.userSelectedFee),
                  child: const CustomFlatButton(
                    textLabel: 'Confirm',
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, model.userConfirmedFee),
                  child: const CustomFlatButton(
                    textLabel: 'Cancel',
                    buttonColor: customDarkBackground,
                    fontColor: customWhite,
                  ),
                ),
              ),
            ],
          ),
          child: ListView(
            children: [
              GestureDetector(
                onTap: () => model.setUserSelectedFee('Normal'),
                child: ListTile(
                  title: Row(
                    children: [
                      const Text(
                        'Normal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' (${model.fees['average']} sats/kByte)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: customDarkNeutral7,
                        ),
                      ),
                    ],
                  ),
                  trailing: model.userSelectedFee == 'Normal'
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          color: customYellow,
                        )
                      : null,
                ),
              ),
              GestureDetector(
                onTap: () => model.setUserSelectedFee('Fast'),
                child: ListTile(
                  title: Row(
                    children: [
                      const Text(
                        'Fast',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' (${model.fees['fast']} sats/kByte)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: customDarkNeutral7,
                        ),
                      ),
                    ],
                  ),
                  trailing: model.userSelectedFee == 'Fast'
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          color: customYellow,
                        )
                      : null,
                ),
              ),
              GestureDetector(
                onTap: () => model.setUserSelectedFee('Fastest'),
                child: ListTile(
                  title: Row(
                    children: [
                      const Text(
                        'Fastest',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' (${model.fees['fastest']} sats/kByte)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: customDarkNeutral7,
                        ),
                      ),
                    ],
                  ),
                  trailing: model.userSelectedFee == 'Fastest'
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          color: customYellow,
                        )
                      : null,
                ),
              ),
            ],
          )),
    );
  }
}
