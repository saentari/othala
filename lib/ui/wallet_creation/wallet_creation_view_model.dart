import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

import '../../services/bitcoin_client.dart';
import '../../services/wallet_manager.dart';
import '../../themes/theme_data.dart';

class WalletCreationViewModel extends ChangeNotifier {
  var confirmed = false;
  var randomMnemonic = '';
  var randomMnemonicList = ['', '', '', '', '', '', '', '', '', '', '', ''];

  void initialise(BuildContext context) {
    createMnemonic();
    notifyListeners();
  }

  void toggleConfirmation() {
    confirmed == false ? confirmed = true : confirmed = false;
    notifyListeners();
  }

  createMnemonic() {
    // BIP39 English word list.
    randomMnemonic = generateMnemonic();
    randomMnemonicList = randomMnemonic.split(" ");
  }

  Future<void> encryptToKeyStore(BuildContext context) async {
    EasyLoading.show(
      status: 'creating...',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    final walletManager = WalletManager();
    await walletManager.encryptToKeyStore(
        mnemonic: randomMnemonic, generated: true);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    // if (!mounted) return;
    int jumpToPage = walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
  }

  void setClipboard(BuildContext context) async {
    // Clipboard.
    var data = ClipboardData(text: randomMnemonic);
    Clipboard.setData(data);
    // if (!mounted) return;

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
