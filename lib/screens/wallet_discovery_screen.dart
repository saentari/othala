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
  final WalletManager walletManager = WalletManager(Hive.box('walletBox'));

  bool confirmed = false;
  String walletName = '';
  final List<String> address = [''];
  final List<String> amount = [''];
  late String mnemonic;
  late InputType inputType;

  @override
  Widget build(BuildContext context) {
    if (confirmed == false) {
      getWalletData(ModalRoute.of(context)!.settings.arguments);
    }
    return SafeAreaX(
      appBar: AppBar(
        centerTitle: true,
        title: titleIcon,
        backgroundColor: customBlack,
        automaticallyImplyLeading: false,
      ),
      bottomBar: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => confirmed == true ? encryptToKeyStore() : null,
              child: confirmed == true
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
                buttonColor: customDarkBackground,
                fontColor: customWhite,
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
                  walletName,
                  subtitle: amount[0],
                  icon: Icons.currency_bitcoin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> encryptToKeyStore() async {
    if (inputType == InputType.address) {
      await walletManager.encryptToKeyStore(address: address[0]);
    } else if (inputType == InputType.mnemonic) {
      await walletManager.encryptToKeyStore(mnemonic: mnemonic);
    }
    if (!mounted) return;
    int jumpToPage = walletManager.value.length - 1;
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_screen', (Route<dynamic> route) => false,
        arguments: jumpToPage);
  }

  Future<void> getWalletData(input) async {
    inputType = input[0];
    late String firstAddress;

    if (inputType == InputType.mnemonic) {
      mnemonic = input[1];
      BitcoinClient client = BitcoinClient(mnemonic);
      firstAddress = client.address;
    } else {
      firstAddress = input[1];
    }
    walletName = getAddressName(firstAddress);

    double doubleAmount = await walletManager.getBalance(firstAddress);

    address.insert(0, firstAddress);
    amount.insert(0, '$doubleAmount BTC');
    confirmed = true;
    setState(() {});
  }
}
