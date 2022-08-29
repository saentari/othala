import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class LnUrlConfirmationScreen extends StatefulWidget {
  const LnUrlConfirmationScreen({Key? key}) : super(key: key);

  @override
  _LnUrlConfirmationScreenState createState() =>
      _LnUrlConfirmationScreenState();
}

class _LnUrlConfirmationScreenState extends State<LnUrlConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    final lnurlAuth = ModalRoute.of(context)!.settings.arguments;
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
                'Authenticated 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'You’ve successfully logged in at $lnurlAuth',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: kDarkNeutral5Color,
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Image.asset(
                  'assets/images/george-prentzas-SRFG7iwktDk-unsplash.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/home_screen', (Route<dynamic> route) => false);
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
