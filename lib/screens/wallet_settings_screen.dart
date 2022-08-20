import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:othala/screens/wallet_currency_screen.dart';

import '../models/wallet.dart';
import '../screens/home_screen.dart';
import '../screens/wallet_background_screen.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';
import '../widgets/list_item.dart';

class WalletSettingsScreen extends StatefulWidget {
  const WalletSettingsScreen(this.walletIndex, {Key? key}) : super(key: key);

  final int walletIndex;

  @override
  _WalletSettingsScreenState createState() => _WalletSettingsScreenState();
}

class _WalletSettingsScreenState extends State<WalletSettingsScreen> {
  final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));
  late Wallet _wallet;
  String _defaultFiatCurrency = 'US dollar';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: Hive.box('walletBox').listenable(),
          builder: (context, Box box, widget2) {
            if (widget.walletIndex < box.length) {
              _wallet = box.getAt(widget.walletIndex);
              _defaultFiatCurrency = _walletManager
                  .getDefaultFiatCurrency(widget.walletIndex)
                  .name;
            }
            return Scaffold(
              body: Container(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  left: 8.0,
                  right: 8.0,
                ),
                child: Column(
                  children: [
                    Container(
                      child: SvgPicture.asset(
                        'assets/icons/logo.svg',
                        color: kYellowColor,
                        height: 40.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    WalletCurrencyScreen(widget.walletIndex)));
                      },
                      child: ListItem(
                        'Local currency',
                        subtitle: _defaultFiatCurrency,
                        chevron: true,
                      ),
                    ),
                    const ListDivider(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              WalletBackgroundScreen(widget.walletIndex),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
                      child: ListItem(
                        'Background image',
                        subtitle: 'Select a new background image',
                        chevron: true,
                      ),
                    ),
                    const ListDivider(),
                    GestureDetector(
                      onTap: () {
                        _showDialog();
                      },
                      child: ListItem(
                        'Delete wallet',
                        subtitle: 'Warning: may cause loss of funds',
                        subtitleColor: kRedColor,
                        chevron: true,
                      ),
                    ),
                    Visibility(
                      visible: _wallet.type == 'phrase' ? true : false,
                      child: const ListDivider(),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_wallet.network == 'bitcoin') {
                          _walletManager.setNetwork(
                              widget.walletIndex, 'testnet');
                        } else if (_wallet.network == 'testnet') {
                          _walletManager.setNetwork(
                              widget.walletIndex, 'testnet');
                        }
                      },
                      child: Visibility(
                        visible: _wallet.type == 'phrase' ? true : false,
                        child: ListItem(
                          'Toggle nework',
                          subtitle: 'Selected network: ${_wallet.network}',
                          chevron: true,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const CustomFlatButton(
                              textLabel: 'Cancel',
                              buttonColor: kDarkBackgroundColor,
                              fontColor: kWhiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void _showDialog() {
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
                            "Delete wallet?",
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
                            "Warning: Deleting this wallet without a backup, may result in permanent loss of your assets.",
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
                          onTap: () => _deleteWallet(),
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

  Future<void> _deleteWallet() async {
    await _walletManager.deleteWallet(widget.walletIndex);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const HomeScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
