import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';

import '../services/bitcoin_client.dart';
import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class ImportPhraseScreen extends StatefulWidget {
  const ImportPhraseScreen({Key? key}) : super(key: key);

  @override
  ImportPhraseScreenState createState() => ImportPhraseScreenState();
}

class ImportPhraseScreenState extends State<ImportPhraseScreen> {
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
    return SafeAreaX(
      appBar: AppBar(
        centerTitle: true,
        title: titleIcon,
        backgroundColor: kBlackColor,
        automaticallyImplyLeading: false,
      ),
      bottomBar: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _confirmed == true ? _encryptToKeyStore() : null,
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
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Enter a recovery phrase.',
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
        ],
      ),
    );
  }

  Future<void> _encryptToKeyStore() async {
    EasyLoading.show(
      status: 'importing...',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    final walletManager = WalletManager(Hive.box('walletBox'));

    int purpose = 84;
    BitcoinClient bitcoinClient = BitcoinClient(_mnemonic);

    // check if a derivation path has transactions
    for (int p in [44, 49, 84]) {
      String derivationPath = "m/$p'/0'/0'/0";
      bitcoinClient.setDerivationPath(derivationPath);
      final data =
          await bitcoinClient.getTransactionAddressStats(bitcoinClient.address);
      final txCount =
          data['chain_stats']['tx_count'] + data['mempool_stats']['tx_count'];
      if (txCount > 0) {
        purpose = p;
        break;
      }
    }

    await walletManager.encryptToKeyStore(
        mnemonic: _mnemonic, purpose: purpose);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (!mounted) return;
    int jumpToPage = walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
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
