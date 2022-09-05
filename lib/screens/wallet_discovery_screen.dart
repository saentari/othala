import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:othala/enums/input_type.dart';

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
  List<String> _address = [''];
  List<String> _amount = ['0'];
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
                      'Address',
                      subtitle: _address[0],
                    ),
                    ListItem(
                      'Balance',
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
    print('storing: $_inputType');
    if (_inputType == InputType.address) {
      _walletManager.encryptToKeyStore(address: _address[0]);
    } else if (_inputType == InputType.mnemonic) {
      _walletManager.encryptToKeyStore(mnemonic: _mnemonic);
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_screen', (Route<dynamic> route) => false);
  }

  Future<void> getWalletData(input) async {
    _inputType = input[0];
    late AssetAddress _firstAddress;

    if (_inputType == InputType.mnemonic) {
      _mnemonic = input[1];
      BitcoinClient _client = BitcoinClient(_mnemonic);
      _firstAddress = AssetAddress(_client.address, 84, 'bitcoin');
    } else {
      _firstAddress = input[1];
    }

    double _doubleAmount = await _walletManager.getBalance(
        _firstAddress.address, _firstAddress.networkType);

    _address.insert(0, _firstAddress.address);
    _amount.insert(0, '$_doubleAmount BTC');
    _confirmed = true;
    setState(() {});
  }
}
