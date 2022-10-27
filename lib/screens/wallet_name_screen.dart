import 'package:flutter/material.dart';

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
  late Wallet wallet;

  var confirmed = false;

  var myTextController = TextEditingController();
  var walletManager = WalletManager();

  @override
  void initState() {
    super.initState();
    myTextController.addListener(validateName);
  }

  @override
  void dispose() {
    myTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    wallet = walletManager.value.getAt(walletIndex);
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
              onTap: () => confirmed == true
                  ? setWalletName(walletIndex, myTextController.text)
                  : null,
              child: confirmed == true
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
              'Description.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: customBlack,
            ),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(fontSize: 20),
                  controller: myTextController,
                  maxLength: 21,
                  decoration: InputDecoration(
                    hintText: wallet.name,
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

  Future<void> setWalletName(int index, String walletName) async {
    walletManager.setWalletValue(index, name: walletName);
    var jumpToPage = walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
  }

  void validateName() {
    if (myTextController.text.isNotEmpty) {
      confirmed = true;
      setState(() {});
    }
  }
}
