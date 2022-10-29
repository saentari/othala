import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../services/wallet_manager.dart';
import '../../utils/utils.dart';

class ImportAddressViewModel extends ChangeNotifier {
  var confirmed = false;
  var textController = TextEditingController();

  late String address;

  void initialise(BuildContext context) {
    textController.addListener(validateAddress);
    notifyListeners();
  }

  Future<void> importWallet(BuildContext context) async {
    EasyLoading.show(
      status: 'importing...',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    var walletManager = WalletManager();
    await walletManager.encryptToKeyStore(address: address);
    if (EasyLoading.isShow) EasyLoading.dismiss();
    // if (!mounted) return;
    var jumpToPage = walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
  }

  void getClipboard() async {
    var data = await Clipboard.getData('text/plain');
    textController.text = data!.text!;
  }

  void validateAddress() {
    // Strip any bitcoin prefix
    address = textController.text
        .replaceFirst(RegExp(r'bitcoin:', caseSensitive: false), '');
    if (textController.text.isNotEmpty) {
      confirmed = isValidAddress(address);
      notifyListeners();
    }
  }
}
