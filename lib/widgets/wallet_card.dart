import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/currency.dart';
import '../models/wallet.dart';
import '../screens/receive_payment_screen.dart';
import '../screens/send_payment_screen.dart';
import '../screens/wallet_screen.dart';
import '../services/exchange_manager.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class WalletCard extends StatefulWidget {
  const WalletCard(this.walletIndex, {Key? key}) : super(key: key);

  final int walletIndex;

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  final ExchangeManager _exchangeManager = ExchangeManager();
  final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));
  final Currency _bitcoin = Currency('BTC', priceUsd: 1.0);
  final Currency _satoshi = Currency('SATS', priceUsd: 100000000.0);
  var _format = NumberFormat("0.########", "en_US");
  num _balance = 0.0;
  num _amount = 0.0;

  late Currency _defaultCurrency;
  late Currency _defaultFiatCurrency;
  late Wallet _wallet;

  @override
  void initState() {
    super.initState();
    Box _box = Hive.box('walletBox');
    if (widget.walletIndex < _box.length) {
      _wallet = _box.getAt(widget.walletIndex);
    }
    if (_wallet.balance.isNotEmpty) {
      _amount = _wallet.balance.first;
    }
    _defaultCurrency = _walletManager.getDefaultCurrency(widget.walletIndex);
    _defaultFiatCurrency =
        _walletManager.getDefaultFiatCurrency(widget.walletIndex);
    // use stored price
    _balance = _amount * _defaultCurrency.priceUsd;
    // retrieve new price
    _updateCurrency(_defaultCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: Hive.box('walletBox').listenable(),
          builder: (context, Box box, widget2) {
            return Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    WalletScreen(widget.walletIndex),
                              ),
                            ).then((value) {
                              setState(() {});
                            });
                          },
                          child: Hero(
                            tag: 'imageHero',
                            child: _showImage(),
                          ),
                        ),
                        Positioned(
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
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _format.format(_balance),
                                    style: const TextStyle(
                                      color: kWhiteColor,
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    _defaultCurrency.code,
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
      _format = NumberFormat("0.########", "en_US");
    } else if (newCurrency.code == _satoshi.code) {
      _defaultCurrency = _satoshi;
      _format = NumberFormat("0.########", "en_US");
    } else {
      // if newCurrency is not bitcoin or satoshi, then fiat.
      _defaultCurrency = newCurrency;
      _format = NumberFormat.simpleCurrency(name: _defaultCurrency.code);
    }
    _walletManager.setDefaultCurrency(widget.walletIndex, _defaultCurrency);
    _balance = _amount * _defaultCurrency.priceUsd;
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
