import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../enums/input_type.dart';
import '../services/bitcoin_client.dart';
import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_item.dart';
import '../widgets/safe_area.dart';

class WalletDiscoveryScreen extends StatefulWidget {
  const WalletDiscoveryScreen({Key? key}) : super(key: key);

  @override
  WalletDiscoveryScreenState createState() => WalletDiscoveryScreenState();
}

class WalletDiscoveryScreenState extends State<WalletDiscoveryScreen> {
  final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));

  bool _confirmed = false;
  String _walletName = '';
  final List<String> _address = [''];
  final List<String> _amount = [''];
  late String _mnemonic;
  late InputType _inputType;

  @override
  Widget build(BuildContext context) {
    if (_confirmed == false) {
      getWalletData(ModalRoute.of(context)!.settings.arguments);
    }
    return SafeAreaX(
      appBar: AppBar(
        centerTitle: true,
        title: titleIcon,
        backgroundColor: kBlackColor,
        automaticallyImplyLeading: false,
      ),
      bottomBar: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _confirmed == true ? _encryptToKeyStore() : null,
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
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Found something.',
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
        ],
      ),
    );
  }

  Future<void> _encryptToKeyStore() async {
    if (_inputType == InputType.address) {
      await _walletManager.encryptToKeyStore(address: _address[0]);
    } else if (_inputType == InputType.mnemonic) {
      await _walletManager.encryptToKeyStore(mnemonic: _mnemonic);
    }
    if (!mounted) return;
    int jumpToPage = _walletManager.value.length - 1;
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_screen', (Route<dynamic> route) => false,
        arguments: jumpToPage);
  }

  Future<void> getWalletData(input) async {
    _inputType = input[0];
    late String firstAddress;

    if (_inputType == InputType.mnemonic) {
      _mnemonic = input[1];
      BitcoinClient client = BitcoinClient(_mnemonic);
      firstAddress = client.address;
    } else {
      firstAddress = input[1];
    }
    _walletName = getAddressName(firstAddress);

    double doubleAmount = await _walletManager.getBalance(firstAddress);

    _address.insert(0, firstAddress);
    _amount.insert(0, '$doubleAmount BTC');
    _confirmed = true;
    setState(() {});
  }
}
