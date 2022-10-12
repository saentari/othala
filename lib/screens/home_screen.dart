import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

import '../themes/theme_data.dart';
import '../widgets/wallet_card.dart';
import '../widgets/wallet_card_new.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _controller;
  final _currentPageNotifier = ValueNotifier<int>(0);
  final Box _walletBox = Hive.box('walletBox');

  @override
  Widget build(BuildContext context) {
    final initialPage = ModalRoute.of(context)!.settings.arguments ?? 0;
    _controller = PageController(initialPage: initialPage as int);
    _currentPageNotifier.value = initialPage;
    return Container(
      color: kDarkBackgroundColor,
      child: SafeArea(
        child: ValueListenableBuilder(
            valueListenable: Hive.box('walletBox').listenable(),
            builder: (context, Box box, widget) {
              return Scaffold(
                body: Container(
                  padding: const EdgeInsets.only(
                    bottom: 16.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              'assets/icons/logo.svg',
                              color: kYellowColor,
                              height: 40.0,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.crop_free),
                              onPressed: () {
                                Navigator.pushNamed(context, '/camera_screen');
                              },
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _walletBox.length + 1,
                            controller: _controller,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == _walletBox.length) {
                                return const WalletCardNew();
                              } else {
                                return WalletCard(index);
                              }
                            },
                            onPageChanged: (int index) {
                              _currentPageNotifier.value = index;
                            }),
                      ),
                      // Ignore CirclePageIndicator when fewer than 2 screens.
                      Visibility(
                        visible: _walletBox.length > 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: CirclePageIndicator(
                              size: 8.0,
                              selectedSize: 12.0,
                              dotColor: kWhiteColor,
                              selectedDotColor: kYellowColor,
                              itemCount: _walletBox.length + 1,
                              currentPageNotifier: _currentPageNotifier,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
