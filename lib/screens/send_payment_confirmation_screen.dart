import 'package:flutter/material.dart';

import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class SendPaymentConfirmationScreen extends StatefulWidget {
  const SendPaymentConfirmationScreen({Key? key}) : super(key: key);

  @override
  SendPaymentConfirmationScreenState createState() =>
      SendPaymentConfirmationScreenState();
}

class SendPaymentConfirmationScreenState
    extends State<SendPaymentConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeAreaX(
      appBar: AppBar(
        centerTitle: true,
        title: titleIcon,
        backgroundColor: kBlackColor,
        automaticallyImplyLeading: false,
      ),
      bottomBar: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/home_screen'),
        child: const CustomFlatButton(
          textLabel: 'Close',
          buttonColor: kDarkBackgroundColor,
          fontColor: kWhiteColor,
        ),
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'Transaction sent 🎉',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'It usually takes about 60 minutes for a transaction to be finalized.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: kDarkNeutral5Color,
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: Image.asset(
              'assets/images/brina-blum-eAK1PMf-9W8-unsplash.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
