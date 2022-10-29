import 'package:flutter/cupertino.dart';

class CameraErrorViewModel extends ChangeNotifier {
  late String qrBarcodeString;

  void initialise(BuildContext context) {
    // [qrBarcodeString] is parsed when failed to identify this as an input
    qrBarcodeString = ModalRoute.of(context)!.settings.arguments as String;
    notifyListeners();
  }
}
