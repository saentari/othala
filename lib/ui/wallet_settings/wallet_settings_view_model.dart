import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/wallet.dart';
import '../../services/wallet_manager.dart';
import '../../themes/theme_data.dart';

class WalletSettingsViewModel extends ChangeNotifier {
  final walletManager = WalletManager();
  var defaultFiatCurrency = 'US dollar';

  late Wallet wallet;
  late int walletIndex;

  void initialise(BuildContext context) {
    walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    var box = Hive.box('walletBox');
    if (walletIndex < box.length) {
      wallet = box.getAt(walletIndex);
      defaultFiatCurrency =
          walletManager.getDefaultFiatCurrency(walletIndex).name;
    }
    notifyListeners();
  }

  Future<void> deleteWallet(BuildContext context, int walletIndex) async {
    await walletManager.deleteWallet(walletIndex);

    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_screen', (Route<dynamic> route) => false);
  }

  void deleteWalletDialog(BuildContext context, int walletIndex) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: customDarkNeutral1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 200,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Center(
                          child: Text(
                            "Are you sure?",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 22.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(16.0),
                        child: const Center(
                          child: Text(
                            "Warning: Deleting without a backup, may result in permanent loss of your funds.",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                              color: customYellow,
                            ),
                            child: const Center(
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    color: customDarkBackground,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          onTap: () => deleteWallet(context, walletIndex),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: customDarkForeground,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
