import 'package:flutter/material.dart';

import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class LnUrlConfirmationScreen extends StatefulWidget {
  const LnUrlConfirmationScreen({Key? key}) : super(key: key);

  @override
  LnUrlConfirmationScreenState createState() => LnUrlConfirmationScreenState();
}

class LnUrlConfirmationScreenState extends State<LnUrlConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    final lnurlAuth = ModalRoute.of(context)!.settings.arguments;
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
          const Text(
            'Success 🎉',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'You’ve successfully signed in at $lnurlAuth',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: customDarkNeutral5,
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: Image.asset(
              'assets/images/george-prentzas-SRFG7iwktDk-unsplash.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
