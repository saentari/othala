import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/wallet.dart';
import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class WalletNameScreen extends StatefulWidget {
  const WalletNameScreen({Key? key}) : super(key: key);

  @override
  WalletNameScreenState createState() => WalletNameScreenState();
}

class WalletNameScreenState extends State<WalletNameScreen> {
  late Wallet _wallet;

  bool _confirmed = false;

  final _myTextController = TextEditingController();
  final _walletManager = WalletManager(Hive.box('walletBox'));

  @override
  void initState() {
    super.initState();
    _myTextController.addListener(_validateName);
  }

  @override
  void dispose() {
    _myTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    _wallet = _walletManager.value.getAt(walletIndex);
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
              onTap: () => _confirmed == true
                  ? _setWalletName(walletIndex, _myTextController.text)
                  : null,
              child: _confirmed == true
                  ? const CustomFlatButton(
                      textLabel: 'Save',
                    )
                  : const CustomFlatButton(
                      textLabel: 'Save',
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
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Description.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: kBlackColor,
            ),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(fontSize: 20),
                  controller: _myTextController,
                  maxLength: 21,
                  decoration: InputDecoration(
                    hintText: _wallet.name,
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setWalletName(index, walletName) async {
    _walletManager.setWalletValue(index, name: walletName);

    int jumpToPage = _walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
  }

  void _validateName() {
    if (_myTextController.text.isNotEmpty) {
      _confirmed = true;
      setState(() {});
    }
  }
}
