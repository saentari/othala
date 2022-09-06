import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class LnurlScreen extends StatefulWidget {
  const LnurlScreen({Key? key}) : super(key: key);

  @override
  _LnurlScreenState createState() => _LnurlScreenState();
}

class _LnurlScreenState extends State<LnurlScreen> {
  @override
  Widget build(BuildContext context) {
    final lnurlAuth =
        ModalRoute.of(context)!.settings.arguments as LNURLAuthParams;

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
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: kTransparentColor,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Website',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: kDarkNeutral5Color,
                          ),
                        ),
                        Text(
                          lnurlAuth.domain,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _authenticate(lnurlAuth),
                      child: const CustomFlatButton(
                        textLabel: 'Authenticate',
                      ),
                    ),
                  ),
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

  _authenticate(lnurlAuth) {
    print('authenticating...');
    Navigator.pushNamed(context, '/lnurl_confirmation_screen',
        arguments: lnurlAuth.domain);
  }
}
