import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:hive/hive.dart';

import '../services/bitcoin_client.dart';
import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class WalletCreationScreen extends StatefulWidget {
  const WalletCreationScreen({Key? key}) : super(key: key);

  @override
  WalletCreationScreenState createState() => WalletCreationScreenState();
}

class WalletCreationScreenState extends State<WalletCreationScreen> {
  bool confirmed = false;
  String randomMnemonic = '';

  List<String> randomMnemonicList = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  ];

  @override
  void initState() {
    super.initState();
    createMnemonic();
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaX(
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
              onTap: () => confirmed == true ? encryptToKeyStore() : null,
              child: confirmed == true
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
                        randomMnemonicList[0],
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
                        randomMnemonicList[1],
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
                        randomMnemonicList[2],
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
                        randomMnemonicList[3],
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
                        randomMnemonicList[4],
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
                        randomMnemonicList[5],
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
                        randomMnemonicList[6],
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
                        randomMnemonicList[7],
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
                        randomMnemonicList[8],
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
                        randomMnemonicList[9],
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
                        randomMnemonicList[10],
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
                        randomMnemonicList[11],
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
                onTap: () {
                  setClipboard();
                },
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
            onTap: () => toggleConfirmation(),
            child: Row(
              children: [
                confirmed
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
    );
  }

  void toggleConfirmation() {
    setState(() {
      confirmed == false ? confirmed = true : confirmed = false;
    });
  }

  createMnemonic() {
    // BIP39 English word list.
    randomMnemonic = generateMnemonic();
    randomMnemonicList = randomMnemonic.split(" ");
    setState(() {});
  }

  Future<void> encryptToKeyStore() async {
    EasyLoading.show(
      status: 'creating...',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    final walletManager = WalletManager(Hive.box('walletBox'));
    await walletManager.encryptToKeyStore(
        mnemonic: randomMnemonic, generated: true);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (!mounted) return;
    int jumpToPage = walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
  }

  void setClipboard() async {
    // Clipboard.
    ClipboardData data = ClipboardData(text: randomMnemonic);
    await Clipboard.setData(data);
    if (!mounted) return;

    // Emoji.
    var parser = EmojiParser();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          // Returns: `Copied to clipboard 👍`.
          parser.emojify('Copied to clipboard :thumbsup:'),
          style: const TextStyle(color: customWhite, fontSize: 16.0),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: customDarkGrey,
      ),
    );
  }
}
