import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  initState() {
    super.initState();
    // Fetches prices and updates transactions at start-up.
    WalletManager().updateFiatPrices();
    WalletManager().setTransactions();

    // Show a placeholder when data is being retrieved.
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: customDarkBackground,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.only(
              bottom: 16.0,
              left: 8.0,
              right: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Center(child: logoTextIcon),
                const Spacer(),
                const Text(
                  'Your keys, your bitcoin.\n100% open-source & open-design',
                  style: TextStyle(
                      color: customDarkNeutral7,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
