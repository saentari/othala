import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/safe_area.dart';
import '../widgets/wallet_card.dart';
import '../widgets/wallet_card_new.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? pageController;
  final currentPageNotifier = ValueNotifier<int>(0);
  final Box walletBox = Hive.box('walletBox');

  @override
  Widget build(BuildContext context) {
    final initialPage = ModalRoute.of(context)!.settings.arguments ?? 0;
    pageController = PageController(initialPage: initialPage as int);
    currentPageNotifier.value = initialPage;
    return ValueListenableBuilder(
        valueListenable: Hive.box('walletBox').listenable(),
        builder: (context, Box box, widget) {
          return SafeAreaX(
            appBar: AppBar(
              centerTitle: true,
              title: titleIcon,
              backgroundColor: customTransparent,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.crop_free),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/camera_screen'),
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
                        itemCount: walletBox.length + 1,
                        controller: pageController,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == walletBox.length) {
                            return const WalletCardNew();
                          } else {
                            return WalletCard(index);
                          }
                        },
                        onPageChanged: (int index) {
                          currentPageNotifier.value = index;
                        }),
                  ),
                  // Ignore CirclePageIndicator when fewer than 2 screens.
                  Visibility(
                    visible: walletBox.length > 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: CirclePageIndicator(
                          size: 8.0,
                          selectedSize: 12.0,
                          dotColor: customWhite,
                          selectedDotColor: customYellow,
                          itemCount: walletBox.length + 1,
                          currentPageNotifier: currentPageNotifier,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
