import 'package:flutter/cupertino.dart';

import '../../models/currency.dart';
import '../../services/wallet_manager.dart';

class WalletCurrencyViewModel extends ChangeNotifier {
  late int walletIndex;
  late Currency defaultFiatCurrency;

  void initialise(BuildContext context) {
    walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    defaultFiatCurrency = WalletManager().getDefaultFiatCurrency(walletIndex);
    notifyListeners();
  }
}
