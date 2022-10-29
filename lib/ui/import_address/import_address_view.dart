import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/safe_area.dart';
import 'import_address_view_model.dart';

class ImportAddressView extends StatelessWidget {
  const ImportAddressView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ImportAddressViewModel>.reactive(
      viewModelBuilder: () => ImportAddressViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
      builder: (context, model, child) => SafeAreaX(
        appBar: AppBar(
          centerTitle: true,
          title: titleIcon,
          backgroundColor: customBlack,
          automaticallyImplyLeading: false,
        ),
        bottomBar: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => model.confirmed == true
                    ? model.importWallet(context)
                    : null,
                child: model.confirmed == true
                    ? const CustomFlatButton(
                        textLabel: 'Import',
                      )
                    : const CustomFlatButton(
                        textLabel: 'Import',
                        enabled: false,
                      ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CustomFlatButton(
                  textLabel: 'Cancel',
                  buttonColor: customDarkBackground,
                  fontColor: customWhite,
                ),
              ),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Enter a bitcoin address.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: customBlack,
              ),
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(fontSize: 20),
                    controller: model.textController,
                    decoration: const InputDecoration(
                      hintText: 'bitcoin address, e.g. bc1...',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  GestureDetector(
                    onTap: () => model.getClipboard(),
                    child: const Text(
                      'Paste from clipboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: customYellow,
                        decoration: TextDecoration.underline,
                      ),
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
