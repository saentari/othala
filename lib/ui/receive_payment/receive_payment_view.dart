import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';

import '../../models/wallet.dart';
import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/safe_area.dart';
import 'receive_payments_view_model.dart';

class ReceivePaymentView extends StatelessWidget {
  final Wallet wallet;

  const ReceivePaymentView(this.wallet, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReceivePaymentViewModel>.reactive(
      viewModelBuilder: () => ReceivePaymentViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
      builder: (context, model, child) => SafeAreaX(
        appBar: AppBar(
          centerTitle: true,
          title: titleIcon,
          backgroundColor: customBlack,
          automaticallyImplyLeading: false,
        ),
        bottomBar: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const CustomFlatButton(
            textLabel: 'Close',
            buttonColor: customDarkBackground,
            fontColor: customWhite,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: customWhite,
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: customDarkBackground,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: customDarkBackground),
                      data: wallet.addresses.last.address,
                      version: QrVersions.auto,
                      size: 320,
                    ),
                    const SizedBox(height: 24.0),
                    GestureDetector(
                      onTap: () {
                        model.setClipboard(
                            context, wallet.addresses.last.address);
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              wallet.addresses.last.address,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: customDarkNeutral4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          const Icon(
                            CupertinoIcons.doc_on_doc_fill,
                            color: customDarkNeutral4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
