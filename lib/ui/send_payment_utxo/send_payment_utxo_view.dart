import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/list_divider.dart';
import '../../widgets/list_item_transaction.dart';
import '../../widgets/safe_area.dart';
import 'send_payment_utxo_view_model.dart';

class SendPaymentUtxoView extends StatelessWidget {
  const SendPaymentUtxoView(this.walletIndex, {Key? key}) : super(key: key);

  final int walletIndex;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SendPaymentUtxoViewModel>.reactive(
      viewModelBuilder: () => SendPaymentUtxoViewModel(),
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
                onTap: () => Navigator.pop(context, model.utxoPicking),
                child: const CustomFlatButton(
                  textLabel: 'Confirm',
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context, model.utxoPicking),
                child: const CustomFlatButton(
                  textLabel: 'Cancel',
                  buttonColor: customDarkBackground,
                  fontColor: customWhite,
                ),
              ),
            ),
          ],
        ),
        child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) =>
              const ListDivider(),
          itemCount: model.transactions.length,
          itemBuilder: (BuildContext context, int index) {
            return ListItemTransaction(
              model.transactions[index].address,
              subtitle: model.transactions[index].dateTime,
              value: model.transactions[index].amount,
              subtitleValue: model.transactions[index].confirmations,
            );
          },
        ),
      ),
    );
  }
}
