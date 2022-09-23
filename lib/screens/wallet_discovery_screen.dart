import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

import '../enums/input_type.dart';
import '../services/bitcoin_client.dart';
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
  String _walletName = 'Unknown wallet';
  final List<String> _address = [''];
  final List<String> _amount = ['0 BTC'];
  late String _mnemonic;
  late InputType _inputType;

  @override
  Widget build(BuildContext context) {
    if (_confirmed == false) {
      getWalletData(ModalRoute.of(context)!.settings.arguments);
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
                      _walletName,
                      subtitle: _amount[0],
                      icon: Icons.currency_bitcoin,
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
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/home_screen', (Route<dynamic> route) => false);
                      },
                      child: const CustomFlatButton(
                        textLabel: 'Close',
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

  Future<void> _encryptToKeyStore() async {
    if (_inputType == InputType.address) {
      await _walletManager.encryptToKeyStore(address: _address[0]);
    } else if (_inputType == InputType.mnemonic) {
      await _walletManager.encryptToKeyStore(mnemonic: _mnemonic);
    }
    int _jumpToPage = _walletManager.value.length - 1;
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_screen', (Route<dynamic> route) => false,
        arguments: _jumpToPage);
  }

  Future<void> getWalletData(input) async {
    _inputType = input[0];
    late String _firstAddress;

    if (_inputType == InputType.mnemonic) {
      _mnemonic = input[1];
      BitcoinClient _client = BitcoinClient(_mnemonic);
      _firstAddress = _client.address;
    } else {
      _firstAddress = input[1];
    }
    _walletName = getAddressName(_firstAddress);

    double _doubleAmount = await _walletManager.getBalance(_firstAddress);

    _address.insert(0, _firstAddress);
    _amount.insert(0, '$_doubleAmount BTC');
    _confirmed = true;
    setState(() {});
  }
}
