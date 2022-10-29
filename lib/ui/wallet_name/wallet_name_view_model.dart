import 'package:flutter/cupertino.dart';

import '../../models/wallet.dart';
import '../../services/wallet_manager.dart';

class WalletNameViewModel extends ChangeNotifier {
  var confirmed = false;
  var myTextController = TextEditingController();
  var walletManager = WalletManager();

  late int walletIndex;
  late Wallet wallet;

  void initialise(BuildContext context) {
    myTextController.addListener(validateName);
    walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    wallet = walletManager.value.getAt(walletIndex);
    notifyListeners();
  }

  Future<void> setWalletName(
      BuildContext context, int index, String walletName) async {
    walletManager.setWalletValue(index, name: walletName);
    var jumpToPage = walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
  }

  void validateName() {
    if (myTextController.text.isNotEmpty) {
      confirmed = true;
      notifyListeners();
    }
  }
}
