import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/wallet.dart';
import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';
import '../widgets/list_item.dart';
import '../widgets/safe_area.dart';

class WalletSettingsScreen extends StatefulWidget {
  const WalletSettingsScreen({Key? key}) : super(key: key);

  @override
  WalletSettingsScreenState createState() => WalletSettingsScreenState();
}

class WalletSettingsScreenState extends State<WalletSettingsScreen> {
  final _walletManager = WalletManager(Hive.box('walletBox'));
  late Wallet _wallet;
  String _defaultFiatCurrency = 'US dollar';

  @override
  Widget build(BuildContext context) {
    final walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    return ValueListenableBuilder(
      valueListenable: Hive.box('walletBox').listenable(),
      builder: (context, Box box, widget2) {
        if (walletIndex < box.length) {
          _wallet = box.getAt(walletIndex);
          _defaultFiatCurrency =
              _walletManager.getDefaultFiatCurrency(walletIndex).name;
        }
        return SafeAreaX(
          appBar: AppBar(
            centerTitle: true,
            title: titleIcon,
            backgroundColor: kBlackColor,
            automaticallyImplyLeading: false,
          ),
          bottomBar: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CustomFlatButton(
              textLabel: 'Close',
              buttonColor: kDarkBackgroundColor,
              fontColor: kWhiteColor,
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/wallet_name_screen',
                    arguments: walletIndex,
                  );
                },
                child: ListItem(
                  'Description',
                  subtitle: _wallet.name,
                  chevron: true,
                ),
              ),
              const ListDivider(),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/wallet_currency_screen',
                    arguments: walletIndex,
                  );
                },
                child: ListItem(
                  'Local currency',
                  subtitle: _defaultFiatCurrency,
                  chevron: true,
                ),
              ),
              const ListDivider(),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/wallet_background_screen',
                    arguments: walletIndex,
                  );
                },
                child: const ListItem(
                  'Background image',
                  subtitle: 'Select a new background image',
                  chevron: true,
                ),
              ),
              const ListDivider(),
              GestureDetector(
                onTap: () {
                  _showDialog(walletIndex);
                },
                child: const ListItem(
                  'Delete',
                  subtitle: 'Warning: may cause loss of funds',
                  subtitleColor: kRedColor,
                  chevron: true,
                ),
              ),
              Visibility(
                visible: _wallet.type == 'mnemonic' ? true : false,
                child: const ListDivider(),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/wallet_network_screen',
                    arguments: walletIndex,
                  );
                },
                child: Visibility(
                  visible: _wallet.type == 'mnemonic' ? true : false,
                  child: ListItem(
                    'Toggle network',
                    subtitle:
                        'Selected network: ${_walletManager.getNetworkType(_wallet.derivationPath)}',
                    chevron: true,
                  ),
                ),
              ),
              Visibility(
                visible: _wallet.type == 'mnemonic' ? true : false,
                child: const ListDivider(),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/wallet_derivation_screen',
                    arguments: walletIndex,
                  );
                },
                child: Visibility(
                  visible: _wallet.type == 'mnemonic' ? true : false,
                  child: ListItem(
                    'Change derivation path',
                    subtitle: _wallet.derivationPath,
                    chevron: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialog(walletIndex) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: kDarkNeutral1Color,
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
                              color: kYellowColor,
                            ),
                            child: const Center(
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    color: kDarkBackgroundColor,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          onTap: () => _deleteWallet(walletIndex),
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
                                    color: kDarkForegroundColor,
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

  Future<void> _deleteWallet(walletIndex) async {
    await _walletManager.deleteWallet(walletIndex);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_screen', (Route<dynamic> route) => false);
  }
}
