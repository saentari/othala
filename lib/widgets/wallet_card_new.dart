import 'package:flutter/material.dart';

import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class WalletCardNew extends StatefulWidget {
  const WalletCardNew({Key? key}) : super(key: key);

  @override
  State<WalletCardNew> createState() => _WalletCardNewState();
}

class _WalletCardNewState extends State<WalletCardNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customBlack,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                'assets/images/geran-de-klerk-qzgN45hseN0-unsplash.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/wallet_creation_screen');
                        },
                        child: const CustomFlatButton(textLabel: 'Create'))),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/wallet_import_screen');
                    },
                    child: const CustomFlatButton(
                      textLabel: 'Import',
                      buttonColor: customDarkBackground,
                      fontColor: customWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
