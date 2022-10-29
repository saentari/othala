import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/list_divider.dart';
import '../../widgets/safe_area.dart';
import 'lnurl_view_model.dart';

class LnurlView extends StatelessWidget {
  const LnurlView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LnurlViewModel>.reactive(
      viewModelBuilder: () => LnurlViewModel(),
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
                onTap: () => model.signed != -1
                    ? model.authenticate(context, model.callBackUrl)
                    : null,
                child: CustomFlatButton(
                  textLabel: 'Sign in',
                  enabled: model.signed != -1 ? true : false,
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
                  buttonColor: customDarkBackground,
                  fontColor: customWhite,
                ),
              ),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: const [
                Text(
                  'Website',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: customDarkNeutral5,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  model.domain,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: ListDivider(),
            ),
            Row(
              children: [
                Text(
                  model.wallets.isNotEmpty ? 'Sign in with keys from:' : '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: customDarkNeutral5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                itemCount: model.wallets.length,
                itemBuilder: (BuildContext ctx, index) {
                  var wallet = model.wallets[index];
                  return GestureDetector(
                    onTap: () {
                      model.signed = index;
                      model.sign(wallet, model.lnURL);
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: model.showImage(
                              context,
                              wallet.imagePath,
                              model.signed == index || model.signed == -1
                                  ? 1.0
                                  : 0.5),
                        ),
                        Visibility(
                          visible: model.signed == index ? true : false,
                          child: const Positioned(
                            top: 8.0,
                            right: 8.0,
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: customYellow,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
