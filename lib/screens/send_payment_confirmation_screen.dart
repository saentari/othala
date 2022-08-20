import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class SendPaymentConfirmationScreen extends StatefulWidget {
  const SendPaymentConfirmationScreen({Key? key}) : super(key: key);

  @override
  _SendPaymentConfirmationScreenState createState() =>
      _SendPaymentConfirmationScreenState();
}

class _SendPaymentConfirmationScreenState
    extends State<SendPaymentConfirmationScreen> {
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
              const SizedBox(height: 8.0),
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/home_screen');
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
            ],
          ),
        ),
      ),
    );
  }
}
