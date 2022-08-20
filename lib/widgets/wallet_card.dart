import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:othala/models/currency.dart';
import 'package:othala/services/exchange_manager.dart';
import 'package:othala/services/wallet_manager.dart';

import '../models/wallet.dart';
import '../screens/receive_payment_screen.dart';
import '../screens/send_payment_screen.dart';
import '../screens/wallet_screen.dart';
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

  late Wallet _wallet;

  String _currencyUnit = 'btc';
  Currency _defaultFiatCurrency =
      Currency('USD', id: 'usd-us-dollars', name: 'US dollar', symbol: r'$');
  num _balance = 0.0;
  num _amount = 0.0;
  double _price = 1;
  int _denominator = 1;
  var format = NumberFormat("0.########", "en_US");

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: Hive.box('walletBox').listenable(),
          builder: (context, Box box, widget2) {
            _initialize(box);
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
                            onTap: () => _changeCurrency(),
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
                                    format.format(_balance),
                                    style: const TextStyle(
                                      color: kWhiteColor,
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    _currencyUnit,
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

  void _initialize(box) {
    if (widget.walletIndex < box.length) {
      _wallet = box.getAt(widget.walletIndex);
    }
    if (_wallet.balance.isNotEmpty) {
      _amount = _wallet.balance.first;
    }
    _balance = _amount * _price * _denominator;
  }

  _changeCurrency() async {
    _defaultFiatCurrency =
        _walletManager.getDefaultFiatCurrency(widget.walletIndex);

    if (_currencyUnit == 'btc') {
      _currencyUnit = 'sats';
      _denominator = 100000000;
      _price = 1;
      format = NumberFormat("0.########", "en_US");
    } else if (_currencyUnit == 'sats') {
      _currencyUnit = _defaultFiatCurrency.code;
      // when amount is zero, price doesn't matter for balance.
      if (_amount != 0) {
        _price = await _exchangeManager.getPrice(_defaultFiatCurrency.code);
      }
      _denominator = 1;
      format = NumberFormat.simpleCurrency(name: _defaultFiatCurrency.code);
    } else {
      _currencyUnit = 'btc';
      _price = 1;
      _denominator = 1;
      format = NumberFormat("0.########", _defaultFiatCurrency.locale);
    }
    setState(() {});
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
