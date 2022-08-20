import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:xchain_dart/xchaindart.dart';

import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
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
  late String _address;
  bool _confirmed = false;
  final _walletManager = WalletManager(Hive.box('walletBox'));

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
                    _validateAddress(scanData.code);
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

  void _importWallet() {
    _walletManager.encryptToKeyStore(address: _address);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/home_screen');
  }

  void _validateAddress(input) {
    _address = _stripMeta(input);
    _confirmed = _walletManager.validateAddress(_address);
    if (_confirmed == true) {
      _importWallet();
    } else {
      Navigator.pop(context);
    }
  }

  String _stripMeta(source) {
    // strip meta-data (e.g. bitcoin:bc1...).
    List<AssetAddress> _addresses = substractAddress(source);
    return _addresses.first.address;
  }
}
