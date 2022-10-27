import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../services/bitcoin_client.dart' as bitcoin_client;
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
  var myTextController = TextEditingController();
  var confirmed = false;
  var mnemonic = '';

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    myTextController.addListener(validateMnemonic);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myTextController.dispose();
    super.dispose();
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
              'Enter a recovery phrase.',
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
                  controller: myTextController,
                  decoration: const InputDecoration(
                    hintText: 'use spaces between words.',
                  ),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () {
                    getClipboard();
                  },
                  child: const Text(
                    'Paste from clipboard',
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
          ),
        ],
      ),
    );
  }

  Future<void> encryptToKeyStore() async {
    EasyLoading.show(
      status: 'importing...',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    var purpose = 84;
    var bitcoinClient = bitcoin_client.BitcoinClient(mnemonic);

    // check if a derivation path has transactions
    for (int p in [44, 49, 84]) {
      bitcoinClient.setDerivationPath("m/$p'/0'/0'/0");
      var data =
          await bitcoinClient.getTransactionAddressStats(bitcoinClient.address);
      var txCount =
          data['chain_stats']['tx_count'] + data['mempool_stats']['tx_count'];
      if (txCount > 0) {
        purpose = p;
        break;
      }
    }
    var walletManager = WalletManager();
    await walletManager.encryptToKeyStore(mnemonic: mnemonic, purpose: purpose);
    if (EasyLoading.isShow) EasyLoading.dismiss();
    if (!mounted) return;
    var jumpToPage = walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
  }

  void getClipboard() async {
    var data = await Clipboard.getData('text/plain');
    mnemonic = data!.text!;
    myTextController.text = mnemonic;
  }

  void validateMnemonic() {
    if (myTextController.text.isNotEmpty) {
      mnemonic = myTextController.text;
      setState(() => confirmed = bitcoin_client.validateMnemonic(mnemonic));
    }
  }
}
