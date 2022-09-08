import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

import '../services/bitcoin_client.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class WalletCreationScreen extends StatefulWidget {
  const WalletCreationScreen({Key? key}) : super(key: key);

  @override
  _WalletCreationScreenState createState() => _WalletCreationScreenState();
}

class _WalletCreationScreenState extends State<WalletCreationScreen> {
  bool _confirmed = false;
  String _randomMnemonic = '';

  List<String> _randomMnemonicList = [
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
    _createMnemonic();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(
            bottom: 16.0,
            left: 8.0,
            right: 8.0,
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SvgPicture.asset(
                  'assets/icons/logo.svg',
                  color: kYellowColor,
                  height: 40.0,
                ),
              ),
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
                                color: kGreyColor,
                              ),
                            ),
                          ),
                          Text(
                            _randomMnemonicList[0],
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
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[1],
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
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[2],
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
                                color: kGreyColor,
                              ),
                            ),
                          ),
                          Text(
                            _randomMnemonicList[3],
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
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[4],
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
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[5],
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
                                color: kGreyColor,
                              ),
                            ),
                          ),
                          Text(
                            _randomMnemonicList[6],
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
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[7],
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
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[8],
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
                                color: kGreyColor,
                              ),
                            ),
                          ),
                          Text(
                            _randomMnemonicList[9],
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
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[10],
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
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[11],
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
                      _setClipboard();
                    },
                    child: const Text(
                      'Copy to clipboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kYellowColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _toggleConfirmation(),
                child: Row(
                  children: [
                    _confirmed
                        ? const Icon(CupertinoIcons.checkmark_square_fill,
                            color: kWhiteColor)
                        : const Icon(CupertinoIcons.square, color: kWhiteColor),
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _confirmed == true ? _encryptToKeyStore() : null,
                      child: _confirmed == true
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
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const CustomFlatButton(
                        textLabel: 'Cancel',
                        buttonColor: kDarkBackgroundColor,
                        fontColor: kWhiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleConfirmation() {
    setState(() {
      _confirmed == false ? _confirmed = true : _confirmed = false;
    });
  }

  _createMnemonic() {
    // BIP39 English word list
    _randomMnemonic = generateMnemonic();
    _randomMnemonicList = _randomMnemonic.split(" ");

    setState(() {});
  }

  Future<void> _encryptToKeyStore() async {
    final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));
    await _walletManager.encryptToKeyStore(mnemonic: _randomMnemonic);
    int _jumpToPage = _walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: _jumpToPage);
  }

  void _setClipboard() async {
    // clipboard
    ClipboardData data = ClipboardData(text: _randomMnemonic);
    await Clipboard.setData(data);

    // emoji
    var parser = EmojiParser();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          // returns: 'Copied to clipboard 👍'
          parser.emojify('Copied to clipboard :thumbsup:'),
          style: const TextStyle(color: kWhiteColor, fontSize: 16.0),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: kDarkGreyColor,
      ),
    );
  }
}
