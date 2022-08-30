import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_item.dart';

class WalletDiscoveryScreen extends StatefulWidget {
  const WalletDiscoveryScreen({Key? key}) : super(key: key);

  @override
  _WalletDiscoveryScreenState createState() => _WalletDiscoveryScreenState();
}

class _WalletDiscoveryScreenState extends State<WalletDiscoveryScreen> {
  final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));

  bool _confirmed = false;
  List<String> _address = [''];
  List<String> _amount = ['0'];
  List<String> _title = ['Bitcoin Wallet'];

  @override
  Widget build(BuildContext context) {
    if (_confirmed == false) {
      getWalletData(
          ModalRoute.of(context)!.settings.arguments as List<AssetAddress>);
    }
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(
            bottom: 16.0,
            left: 8.0,
            right: 8.0,
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SvgPicture.asset(
                  'assets/icons/logo.svg',
                  color: kYellowColor,
                  height: 40.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'A wallet was found',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListItem(
                      _title[0],
                      subtitle: _amount[0],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _confirmed == true ? _encryptToKeyStore() : null,
                      child: _confirmed == true
                          ? const CustomFlatButton(
                              textLabel: 'Import',
                            )
                          : const CustomFlatButton(
                              textLabel: 'Import',
                              enabled: false,
                            ),
                    ),
                  ),
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
      ),
    );
  }

  void _encryptToKeyStore() async {
    _walletManager.encryptToKeyStore(address: _address[0]);
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_screen', (Route<dynamic> route) => false);
  }

  Future<void> getWalletData(input) async {
    // TODO: Support passphrase & key import
    List<AssetAddress> _addresses = input;
    AssetAddress firstAddress = _addresses[0];
    double _doubleAmount = await _walletManager.getBalance(
        firstAddress.address, firstAddress.networkType);
    _address.insert(0, firstAddress.address);
    _title.insert(0, 'Bitcoin Wallet');
    _amount.insert(0, '$_doubleAmount BTC');
    _confirmed = true;
    setState(() {});
  }
}
