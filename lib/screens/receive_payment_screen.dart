import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/wallet.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class ReceivePaymentScreen extends StatefulWidget {
  const ReceivePaymentScreen(this.wallet, {Key? key}) : super(key: key);

  final Wallet wallet;

  @override
  ReceivePaymentScreenState createState() => ReceivePaymentScreenState();
}

class ReceivePaymentScreenState extends State<ReceivePaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeAreaX(
      appBar: AppBar(
        centerTitle: true,
        title: titleIcon,
        backgroundColor: customBlack,
        automaticallyImplyLeading: false,
      ),
      bottomBar: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: const CustomFlatButton(
          textLabel: 'Close',
          buttonColor: customDarkBackground,
          fontColor: customWhite,
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: customWhite,
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
              child: Column(
                children: [
                  QrImageView(
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: customDarkBackground,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: customDarkBackground),
                    data: widget.wallet.addresses.last.address,
                    version: QrVersions.auto,
                    size: 320,
                  ),
                  const SizedBox(height: 24.0),
                  GestureDetector(
                    onTap: () {
                      setClipboard();
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.wallet.addresses.last.address,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: customDarkNeutral4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        const Icon(
                          CupertinoIcons.doc_on_doc_fill,
                          color: customDarkNeutral4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setClipboard() async {
    // Clipboard.
    ClipboardData data =
        ClipboardData(text: widget.wallet.addresses.last.address);
    await Clipboard.setData(data);
    if (!mounted) return;

    // Emoji
    var parser = EmojiParser();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          // Return: 'Copied to clipboard 👍'.
          parser.emojify('Copied to clipboard :thumbsup:'),
          style: const TextStyle(color: customWhite, fontSize: 16.0),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: customDarkGrey,
      ),
    );
  }
}
