import 'package:flutter/material.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/safe_area.dart';
import '../../widgets/wallet_card.dart';
import '../../widgets/wallet_card_new.dart';
import 'home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
      builder: (context, model, child) => SafeAreaX(
        appBar: AppBar(
          centerTitle: true,
          title: titleIcon,
          backgroundColor: customTransparent,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.crop_free),
              onPressed: () => Navigator.pushNamed(context, '/camera_screen'),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.only(
            bottom: 16.0,
            left: 8.0,
            right: 8.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: model.walletBox.length + 1,
                    controller: model.pageController,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == model.walletBox.length) {
                        return const WalletCardNew();
                      } else {
                        return WalletCard(index);
                      }
                    },
                    onPageChanged: (int index) {
                      model.currentPageNotifier.value = index;
                    }),
              ),
              // Ignore CirclePageIndicator when fewer than 2 screens.
              Visibility(
                visible: model.walletBox.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: CirclePageIndicator(
                      size: 8.0,
                      selectedSize: 12.0,
                      dotColor: customWhite,
                      selectedDotColor: customYellow,
                      itemCount: model.walletBox.length + 1,
                      currentPageNotifier: model.currentPageNotifier,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
