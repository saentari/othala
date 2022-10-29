import 'package:flutter/cupertino.dart';

class WalletNetworkViewModel extends ChangeNotifier {
  late int walletIndex;

  void initialise(BuildContext context) {
    walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    notifyListeners();
  }
}
