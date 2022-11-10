import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/address.dart';
import '../../models/currency.dart';
import '../../models/wallet.dart';
import '../../services/wallet_manager.dart';
import '../../utils/utils.dart';

class HomeViewModel extends ChangeNotifier {
  PageController? pageController;
  final currentPageNotifier = ValueNotifier<int>(0);
  final walletBox = Hive.box('walletBox');
  final walletManager = WalletManager();
  final bitcoin = Currency('BTC', priceUsd: 1.0);
  final satoshi = Currency('SATS', priceUsd: 100000000.0);

  var balance = '';

  late Wallet wallet;
  late Currency defaultCurrency;
  late Currency defaultFiatCurrency;

  void initialise(BuildContext context) {
    var initialPage = ModalRoute.of(context)!.settings.arguments ?? 0;
    pageController = PageController(initialPage: initialPage as int);
    currentPageNotifier.value = initialPage;
    showBalance();
    notifyListeners();
  }

  void showBalance() {
    balance = '';
    if (currentPageNotifier.value < walletBox.length) {
      num amount = 0;
      wallet = walletBox.getAt(currentPageNotifier.value);
      for (Address addressObj in wallet.addresses) {
        amount = amount + addressObj.balance;
      }
      // If [amount] is zero, then don't show anything.
      if (amount > 0) {
        defaultCurrency = wallet.defaultCurrency;
        defaultFiatCurrency = wallet.defaultFiatCurrency;
        // use stored price
        var balanceAmount = getNumberFormat(
            currency: defaultCurrency,
            amount: amount * defaultCurrency.priceUsd);
        balance = '$balanceAmount ${defaultCurrency.code.toLowerCase()}';
      }
    }
    notifyListeners();
  }

  toggleDefaultCurrency() async {
    if (defaultCurrency.code == bitcoin.code) {
      updateCurrency(satoshi);
    } else if (defaultCurrency.code == satoshi.code) {
      updateCurrency(defaultFiatCurrency);
    } else {
      updateCurrency(bitcoin);
    }
    notifyListeners();
  }

  updateCurrency(Currency newCurrency) async {
    if (newCurrency.code == bitcoin.code) {
      defaultCurrency = bitcoin;
    } else if (newCurrency.code == satoshi.code) {
      defaultCurrency = satoshi;
    } else {
      // If newCurrency is not bitcoin or satoshi, then fiat.
      defaultCurrency = newCurrency;
    }
    walletManager.setDefaultCurrency(
        currentPageNotifier.value, defaultCurrency);
    // Refresh balance in app bar.
    showBalance();
  }
}
