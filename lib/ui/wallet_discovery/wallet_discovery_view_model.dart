import 'package:flutter/cupertino.dart';

import '../../enums/input_type.dart';
import '../../services/bitcoin_client.dart';
import '../../services/wallet_manager.dart';
import '../../utils/utils.dart';

class WalletDiscoveryViewModel extends ChangeNotifier {
  var confirmed = false;
  var walletName = '';
  var address = [''];
  var amount = [''];

  late String mnemonic;
  late InputType inputType;

  void initialise(BuildContext context) {
    if (confirmed == false) {
      getWalletData(ModalRoute.of(context)!.settings.arguments);
    }
    notifyListeners();
  }

  Future<void> encryptToKeyStore(BuildContext context) async {
    var walletManager = WalletManager();
    if (inputType == InputType.address) {
      await walletManager.encryptToKeyStore(address: address[0]);
    } else if (inputType == InputType.mnemonic) {
      await walletManager.encryptToKeyStore(mnemonic: mnemonic);
    }
    int jumpToPage = walletManager.value.length - 1;
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_screen', (Route<dynamic> route) => false,
        arguments: jumpToPage);
  }

  Future<void> getWalletData(input) async {
    inputType = input[0];
    late String firstAddress;

    if (inputType == InputType.mnemonic) {
      mnemonic = input[1];
      BitcoinClient client = BitcoinClient(mnemonic);
      firstAddress = client.address;
    } else {
      firstAddress = input[1];
    }
    walletName = getAddressName(firstAddress);

    double doubleAmount = await WalletManager().getBalance(firstAddress);

    address.insert(0, firstAddress);
    amount.insert(0, '$doubleAmount BTC');
    confirmed = true;
    notifyListeners();
  }
}
