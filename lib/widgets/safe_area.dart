import 'package:flutter/material.dart';

import '../themes/theme_data.dart';

class SafeAreaX extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomBar;
  const SafeAreaX({
    Key? key,
    this.appBar,
    this.bottomBar,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkBackgroundColor,
      child: SafeArea(
        child: Scaffold(
          appBar: appBar,
          backgroundColor: kBlackColor,
          body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: child),
          bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
                left: 8.0,
                right: 8.0,
              ),
              child: bottomBar),
        ),
      ),
    );
  }
}
