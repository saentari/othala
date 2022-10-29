import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/safe_area.dart';
import 'wallet_creation_view_model.dart';

class WalletCreationView extends StatelessWidget {
  const WalletCreationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletCreationViewModel>.reactive(
      viewModelBuilder: () => WalletCreationViewModel(),
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
                    ? model.encryptToKeyStore(context)
                    : null,
                child: model.confirmed == true
                    ? const CustomFlatButton(
                        textLabel: 'Create',
                      )
                    : const CustomFlatButton(
                        textLabel: 'Create',
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
            const Text(
              'Write down these words in the right order and store them safely. Without these words, you will not be able to recover your funds.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 48.0),
            Column(
              children: [
                Table(
                  columnWidths: const {
                    0: FixedColumnWidth(24.0),
                    2: FixedColumnWidth(24.0),
                    4: FixedColumnWidth(24.0),
                  },
                  children: [
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            '1',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: customGrey,
                            ),
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[0],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '2',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: customGrey,
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[1],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '3',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: customGrey,
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[2],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            '4',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: customGrey,
                            ),
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[3],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '5',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: customGrey,
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[4],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '6',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: customGrey,
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[5],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            '7',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: customGrey,
                            ),
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[6],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '8',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: customGrey,
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[7],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '9',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: customGrey,
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[8],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            '10',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: customGrey,
                            ),
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[9],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '11',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: customGrey,
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[10],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '12',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: customGrey,
                          ),
                        ),
                        Text(
                          model.randomMnemonicList[11],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                GestureDetector(
                  onTap: () => model.setClipboard(context),
                  child: const Text(
                    'Copy to clipboard',
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
            const Spacer(),
            GestureDetector(
              onTap: () => model.toggleConfirmation(),
              child: Row(
                children: [
                  model.confirmed
                      ? const Icon(CupertinoIcons.checkmark_square_fill,
                          color: customWhite)
                      : const Icon(CupertinoIcons.square, color: customWhite),
                  const SizedBox(width: 16.0),
                  const Expanded(
                    child: Text(
                      'I wrote down my recovery phrase and I am aware of the risks of losing it.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
