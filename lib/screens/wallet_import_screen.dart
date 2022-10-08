import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';
import '../widgets/list_item.dart';

class WalletImportScreen extends StatefulWidget {
  const WalletImportScreen({Key? key}) : super(key: key);

  @override
  WalletImportScreenState createState() => WalletImportScreenState();
}

class WalletImportScreenState extends State<WalletImportScreen> {
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
                  'Select one of the available options.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/camera_screen');
                },
                child: const ListItem(
                  'Scan QR code',
                  subtitle: 'Use the camera to scan a QR code.',
                  chevron: true,
                ),
              ),
              const ListDivider(),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/import_phrase_screen');
                },
                child: const ListItem(
                  'Enter recovery phrase',
                  subtitle: 'A combination of 12 to 24 words.',
                  chevron: true,
                ),
              ),
              const ListDivider(),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/import_address_screen');
                },
                child: const ListItem(
                  'Enter bitcoin address',
                  subtitle: 'Addresses are watch-only',
                  chevron: true,
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
      ),
    );
  }
}
