import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

import '../services/bitcoin_client.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class ImportPhraseScreen extends StatefulWidget {
  const ImportPhraseScreen({Key? key}) : super(key: key);

  @override
  _ImportPhraseScreenState createState() => _ImportPhraseScreenState();
}

class _ImportPhraseScreenState extends State<ImportPhraseScreen> {
  final _myTextController = TextEditingController();

  bool _confirmed = false;
  String _mnemonic = '';

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    _myTextController.addListener(_validateMnemonic);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _myTextController.dispose();
    super.dispose();
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
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Enter your recovery phrase to import your wallets.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  color: kBlackColor,
                ),
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(fontSize: 20),
                      controller: _myTextController,
                      decoration: const InputDecoration(
                        hintText: 'use spaces between words.',
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () {
                        _getClipboard();
                      },
                      child: const Text(
                        'Paste from clipboard',
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
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _confirmed == true ? _encryptToKeyStore() : null,
                      child: _confirmed == true
                          ? const CustomFlatButton(
                              textLabel: 'Import',
                            )
                          : const CustomFlatButton(
                              textLabel: 'Import',
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

  _encryptToKeyStore() async {
    final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));
    _walletManager.encryptToKeyStore(mnemonic: _mnemonic);
    Navigator.pushReplacementNamed(context, '/home_screen');
  }

  void _getClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    _mnemonic = data!.text!;
    _myTextController.text = _mnemonic;
  }

  void _validateMnemonic() {
    if (_myTextController.text.isNotEmpty) {
      _mnemonic = _myTextController.text;
      if (validateMnemonic(_mnemonic) == true) {
        setState(() {
          _confirmed = true;
        });
      }
      if (validateMnemonic(_mnemonic) == false) {
        setState(() {
          _confirmed = false;
        });
      }
    }
  }
}
