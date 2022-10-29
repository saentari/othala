import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../services/bitcoin_client.dart' as bitcoin_client;
import '../../services/wallet_manager.dart';

class ImportPhraseViewModel extends ChangeNotifier {
  var myTextController = TextEditingController();
  var confirmed = false;
  var mnemonic = '';

  void initialise(BuildContext context) {
    // Start listening to changes.
    myTextController.addListener(validateMnemonic);
    notifyListeners();
  }

  Future<void> encryptToKeyStore(BuildContext context) async {
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
      confirmed = bitcoin_client.validateMnemonic(mnemonic);
      notifyListeners();
    }
  }
}
