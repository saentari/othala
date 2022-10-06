import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/currency.dart';
import '../models/wallet.dart';
import '../screens/receive_payment_screen.dart';
import '../screens/send_payment_screen.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';

class WalletCard extends StatefulWidget {
  const WalletCard(this.walletIndex, {Key? key}) : super(key: key);

  final int walletIndex;

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));
  final Currency _bitcoin = Currency('BTC', priceUsd: 1.0);
  final Currency _satoshi = Currency('SATS', priceUsd: 100000000.0);
  num _balance = 0.0;

  late Currency _defaultCurrency;
  late Currency _defaultFiatCurrency;
  late Wallet _wallet;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: Hive.box('walletBox').listenable(),
          builder: (context, Box box, widget2) {
            _updateValues(box);
            return Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/wallet_screen',
                              arguments: widget.walletIndex,
                            );
                          },
                          child: Hero(
                            tag: 'imageHero',
                            child: _showImage(),
                          ),
                        ),
                        Visibility(
                          visible: _balance > 0 ? true : false,
                          child: Positioned(
                            top: 48,
                            child: GestureDetector(
                              onTap: () => _toggleDefaultCurrency(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: kBlackColor.withOpacity(0.5),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(40.0),
                                    bottomRight: Radius.circular(40.0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      getNumberFormat(
                                          currency: _defaultCurrency,
                                          amount: _balance),
                                      style: const TextStyle(
                                        color: kWhiteColor,
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      _wallet.defaultCurrency.code,
                                      style: const TextStyle(
                                        color: kWhiteColor,
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Visibility(
                        visible: _checkVisibility(_wallet),
                        child: Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          SendPaymentScreen(widget.walletIndex),
                                    ),
                                  );
                                },
                                child:
                                    const CustomFlatButton(textLabel: 'Send'))),
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  ReceivePaymentScreen(_wallet),
                            ),
                          );
                        },
                        child: const CustomFlatButton(
                          textLabel: 'Receive',
                          buttonColor: kDarkBackgroundColor,
                          fontColor: kWhiteColor,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }

  void _updateValues(Box<dynamic> box) {
    num amount = 0;
    if (widget.walletIndex < box.length) {
      _wallet = box.getAt(widget.walletIndex);
    }
    if (_wallet.balance.isNotEmpty) {
      amount = _wallet.balance.first;
    }
    _defaultCurrency = _wallet.defaultCurrency;
    _defaultFiatCurrency = _wallet.defaultFiatCurrency;
    // use stored price
    _balance = amount * _defaultCurrency.priceUsd;
  }

  _showImage() {
    if (FileSystemEntity.typeSync(_wallet.imagePath) ==
        FileSystemEntityType.notFound) {
      return Image.asset(
        'assets/images/andreas-gucklhorn-mawU2PoJWfU-unsplash.jpeg',
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(_wallet.imagePath),
        fit: BoxFit.cover,
      );
    }
  }

  _toggleDefaultCurrency() async {
    if (_defaultCurrency.code == _bitcoin.code) {
      _updateCurrency(_satoshi);
    } else if (_defaultCurrency.code == _satoshi.code) {
      _updateCurrency(_defaultFiatCurrency);
    } else {
      _updateCurrency(_bitcoin);
    }
  }

  _updateCurrency(Currency newCurrency) async {
    if (newCurrency.code == _bitcoin.code) {
      _defaultCurrency = _bitcoin;
    } else if (newCurrency.code == _satoshi.code) {
      _defaultCurrency = _satoshi;
    } else {
      // if newCurrency is not bitcoin or satoshi, then fiat.
      _defaultCurrency = newCurrency;
    }
    _walletManager.setDefaultCurrency(widget.walletIndex, _defaultCurrency);
  }
}

bool _checkVisibility(Wallet wallet) {
  if (wallet.type != 'address') {
    if (wallet.balance.isNotEmpty) {
      if (wallet.balance.first > 0) {
        return true;
      }
    }
  }
  return false;
}
