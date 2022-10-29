import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../enums/input_type.dart';
import '../../utils/utils.dart';

class CameraViewModel extends ChangeNotifier {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  void initialise(BuildContext context) {
    notifyListeners();
  }

  identifyInput(BuildContext context, String input) async {
    InputType? inputType = getInputType(input);

    if (inputType == InputType.lnurl) {
      var lnurlAuth = await getParams(input);
      // if (!mounted) return;
      if (lnurlAuth.authParams != null) {
        Navigator.pushNamed(
          context,
          '/lnurl_screen',
          arguments: input,
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/camera_error_screen',
          arguments: input,
        );
      }
    } else if (inputType == InputType.address) {
      // Strip any bitcoin prefix
      input = input.replaceFirst(RegExp(r'bitcoin:', caseSensitive: false), '');
      Navigator.pushNamed(context, '/wallet_discovery_screen',
          arguments: [inputType, input]);
    } else if (inputType == InputType.mnemonic) {
      Navigator.pushNamed(context, '/wallet_discovery_screen',
          arguments: [inputType, input]);
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/camera_error_screen',
        arguments: input,
      );
    }
  }
}
