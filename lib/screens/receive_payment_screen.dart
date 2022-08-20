import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/wallet.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class ReceivePaymentScreen extends StatefulWidget {
  const ReceivePaymentScreen(this.wallet, {Key? key}) : super(key: key);

  final Wallet wallet;

  @override
  _ReceivePaymentScreenState createState() => _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends State<ReceivePaymentScreen> {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: kDarkBackgroundColor,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: kDarkBackgroundColor),
                        data: widget.wallet.address.first,
                        version: QrVersions.auto,
                        size: 320,
                      ),
                      const SizedBox(height: 24.0),
                      GestureDetector(
                        onTap: () {
                          _setClipboard();
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.wallet.address.first,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: kDarkNeutral4Color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            const Icon(
                              CupertinoIcons.doc_on_doc_fill,
                              color: kDarkNeutral4Color,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  void _setClipboard() async {
    // clipboard
    ClipboardData data = ClipboardData(text: widget.wallet.address.first);
    await Clipboard.setData(data);

    // emoji
    var parser = EmojiParser();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          // returns: 'Copied to clipboard 👍'
          parser.emojify('Copied to clipboard :thumbsup:'),
          style: const TextStyle(color: kWhiteColor, fontSize: 16.0),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: kDarkGreyColor,
      ),
    );
  }
}
