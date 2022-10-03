import 'dart:io';

import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../enums/input_type.dart';
import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';

void main() => runApp(const MaterialApp(home: CameraScreen()));

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller!.pauseCamera();
    }
    _controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            QRView(
              key: _qrKey,
              onQRViewCreated: (QRViewController controller) {
                _controller = controller;
                _controller!.resumeCamera();
                controller.scannedDataStream.listen((scanData) {
                  if (mounted && scanData.code != '') {
                    _controller!.pauseCamera();
                    _identifyInput(scanData.code);
                  }
                });
              },
              overlay: QrScannerOverlayShape(
                borderWidth: 10,
                borderLength: 20,
                borderRadius: 10,
                borderColor: kWhiteColor,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              top: 0.0,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () async {
                      await _controller?.toggleFlash();
                      setState(() {});
                    },
                    icon: FutureBuilder<bool?>(
                      future: _controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return Icon(snapshot.data!
                              ? Icons.flash_on
                              : Icons.flash_off);
                        } else {
                          return const Icon(Icons.flash_off);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              bottom: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    _controller?.stopCamera();
                    Navigator.pop(context);
                  },
                  child: const CustomFlatButton(textLabel: 'close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _identifyInput(input) async {
    InputType? inputType = getInputType(input);

    if (inputType == InputType.lnurl) {
      final lnurlAuth = await getParams(input);
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
