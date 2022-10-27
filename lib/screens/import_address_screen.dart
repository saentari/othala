import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class ImportAddressScreen extends StatefulWidget {
  const ImportAddressScreen({Key? key}) : super(key: key);

  @override
  ImportAddressScreenState createState() => ImportAddressScreenState();
}

class ImportAddressScreenState extends State<ImportAddressScreen> {
  late String address;

  var confirmed = false;
  var textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.addListener(validateAddress);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () => confirmed == true ? importWallet() : null,
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
              onTap: () => Navigator.pop(context),
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
              'Enter a bitcoin address.',
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
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'bitcoin address, e.g. bc1...',
                  ),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () => getClipboard(),
                  child: const Text(
                    'Paste from clipboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: customYellow,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> importWallet() async {
    EasyLoading.show(
      status: 'importing...',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    var walletManager = WalletManager();
    await walletManager.encryptToKeyStore(address: address);
    if (EasyLoading.isShow) EasyLoading.dismiss();
    if (!mounted) return;
    var jumpToPage = walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
  }

  void getClipboard() async {
    var data = await Clipboard.getData('text/plain');
    textController.text = data!.text!;
  }

  void validateAddress() {
    // Strip any bitcoin prefix
    address = textController.text
        .replaceFirst(RegExp(r'bitcoin:', caseSensitive: false), '');
    if (textController.text.isNotEmpty) {
      confirmed = isValidAddress(address);
      setState(() {});
    }
  }
}
