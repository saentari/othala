import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';

import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/safe_area.dart';
import 'camera_view_model.dart';

class CameraView extends StatelessWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CameraViewModel>.reactive(
      viewModelBuilder: () => CameraViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
      builder: (context, model, child) => SafeAreaX(
        bottomBar: GestureDetector(
          onTap: () {
            model.qrController?.stopCamera();
            Navigator.pop(context);
          },
          child: const CustomFlatButton(textLabel: 'close'),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            QRView(
              key: model.qrKey,
              onQRViewCreated: (QRViewController controller) {
                model.qrController = controller;
                model.qrController!.resumeCamera();
                controller.scannedDataStream.listen((scanData) {
                  if (scanData.code != '' && scanData.code != null) {
                    model.qrController!.pauseCamera();
                    model.identifyInput(context, scanData.code!);
                  }
                });
              },
              overlay: QrScannerOverlayShape(
                borderWidth: 10,
                borderLength: 20,
                borderRadius: 10,
                borderColor: customWhite,
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
                      await model.qrController?.toggleFlash();
                      // setState(() {});
                    },
                    icon: FutureBuilder<bool?>(
                      future: model.qrController?.getFlashStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.data ?? false) {
                          return Icon(snapshot.data!
                              ? Icons.flash_on
                              : Icons.flash_off);
                        }
                        return const Icon(Icons.flash_off);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
