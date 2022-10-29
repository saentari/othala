import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/safe_area.dart';
import 'wallet_background_view_model.dart';

class WalletBackgroundView extends StatelessWidget {
  const WalletBackgroundView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletBackgroundViewModel>.reactive(
      viewModelBuilder: () => WalletBackgroundViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
      builder: (context, model, child) => SafeAreaX(
        appBar: AppBar(
          centerTitle: true,
          title: titleIcon,
          backgroundColor: customBlack,
          automaticallyImplyLeading: false,
        ),
        bottomBar: GestureDetector(
          onTap: () => {Navigator.pop(context)},
          child: const CustomFlatButton(
            textLabel: 'Cancel',
            buttonColor: customDarkBackground,
            fontColor: customWhite,
          ),
        ),
        child: OrientationBuilder(
          builder: (context, orientation) => CustomScrollView(
            slivers: [
              //Grid view with all the images
              model.buildImageGrid(context, model.walletIndex,
                  orientation: orientation),
              // loading indicator at the bottom of the list
              const SliverToBoxAdapter(
                child: LoadingIndicator(customDarkNeutral5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
