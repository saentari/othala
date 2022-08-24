import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:othala/services/wallet_manager.dart';

import '../screens/home_screen.dart';
import '../themes/theme_data.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));

  @override
  initState() {
    super.initState();
    _walletManager.updateFiatPrices();
    // placeholder for verifying data.
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
    return SafeArea(
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
              Center(
                child: SvgPicture.asset(
                  'assets/icons/logo-text.svg',
                  height: 40.0,
                ),
              ),
              const Spacer(),
              const Text(
                'Your wallet, your bitcoin.\n100% open-source & open-design',
                style: TextStyle(
                    color: kDarkNeutral7Color,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
