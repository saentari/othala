import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';

class ImportAddressScreen extends StatefulWidget {
  const ImportAddressScreen({Key? key}) : super(key: key);

  @override
  ImportAddressScreenState createState() => ImportAddressScreenState();
}

class ImportAddressScreenState extends State<ImportAddressScreen> {
  late String _address;

  bool _confirmed = false;

  final _myTextController = TextEditingController();
  final _walletManager = WalletManager(Hive.box('walletBox'));

  @override
  void initState() {
    super.initState();
    _myTextController.addListener(_validateAddress);
  }

  @override
  void dispose() {
    _myTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Enter a bitcoin address.',
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
                      decoration: const InputDecoration(
                        hintText: 'bitcoin address, e.g. bc1...',
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () => _getClipboard(),
                      child: const Text(
                        'Paste from clipboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kYellowColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _confirmed == true ? _importWallet() : null,
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

  Future<void> _importWallet() async {
    await _walletManager.encryptToKeyStore(address: _address);
    if (!mounted) return;
    int jumpToPage = _walletManager.value.length - 1;
    Navigator.pushReplacementNamed(context, '/home_screen',
        arguments: jumpToPage);
  }

  void _getClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    _myTextController.text = data!.text!;
  }

  void _validateAddress() {
    // Strip any bitcoin prefix
    _address = _myTextController.text
        .replaceFirst(RegExp(r'bitcoin:', caseSensitive: false), '');
    if (_myTextController.text.isNotEmpty) {
      _confirmed = isValidAddress(_address);
      setState(() {});
    }
  }
}
