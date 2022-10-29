import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/safe_area.dart';
import 'wallet_name_view_model.dart';

class WalletNameView extends StatelessWidget {
  const WalletNameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletNameViewModel>.reactive(
      viewModelBuilder: () => WalletNameViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
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
                    ? model.setWalletName(
                        context,
                        model.walletIndex,
                        model.myTextController.text,
                      )
                    : null,
                child: model.confirmed == true
                    ? const CustomFlatButton(
                        textLabel: 'Save',
                      )
                    : const CustomFlatButton(
                        textLabel: 'Save',
                        enabled: false,
                      ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
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
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Description.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: customBlack,
              ),
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(fontSize: 20),
                    controller: model.myTextController,
                    maxLength: 21,
                    decoration: InputDecoration(
                      hintText: model.wallet.name,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
