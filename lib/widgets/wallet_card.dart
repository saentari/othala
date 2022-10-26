import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/address.dart';
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
  final WalletManager walletManager = WalletManager(Hive.box('walletBox'));
  final Currency bitcoin = Currency('BTC', priceUsd: 1.0);
  final Currency satoshi = Currency('SATS', priceUsd: 100000000.0);
  num balance = 0.0;

  late Currency defaultCurrency;
  late Currency defaultFiatCurrency;
  late Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: Hive.box('walletBox').listenable(),
          builder: (context, Box box, widget2) {
            updateValues(box);
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
                            child: showImage(),
                          ),
                        ),
                        Visibility(
                          visible: balance > 0 ? true : false,
                          child: Positioned(
                            top: 48,
                            child: GestureDetector(
                              onTap: () => toggleDefaultCurrency(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: customBlack.withOpacity(0.5),
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
                                          currency: defaultCurrency,
                                          amount: balance),
                                      style: const TextStyle(
                                        color: customWhite,
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      wallet.defaultCurrency.code,
                                      style: const TextStyle(
                                        color: customWhite,
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
                        visible: checkVisibility(wallet),
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
                                  ReceivePaymentScreen(wallet),
                            ),
                          );
                        },
                        child: const CustomFlatButton(
                          textLabel: 'Receive',
                          buttonColor: customDarkBackground,
                          fontColor: customWhite,
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

  bool checkVisibility(Wallet wallet) {
    double maxBalance = 0;
    for (Address addressObj in wallet.addresses) {
      maxBalance = maxBalance + addressObj.balance;
    }
    if (wallet.type != 'address' && maxBalance > 0) {
      return true;
    }
    return false;
  }

  void updateValues(Box<dynamic> box) {
    num amount = 0;
    if (widget.walletIndex < box.length) {
      wallet = box.getAt(widget.walletIndex);
    }
    for (Address addressObj in wallet.addresses) {
      amount = amount + addressObj.balance;
    }
    defaultCurrency = wallet.defaultCurrency;
    defaultFiatCurrency = wallet.defaultFiatCurrency;
    // use stored price
    balance = amount * defaultCurrency.priceUsd;
  }

  showImage() {
    if (FileSystemEntity.typeSync(wallet.imagePath) ==
        FileSystemEntityType.notFound) {
      return Image.asset(
        'assets/images/andreas-gucklhorn-mawU2PoJWfU-unsplash.jpeg',
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(wallet.imagePath),
        fit: BoxFit.cover,
      );
    }
  }

  toggleDefaultCurrency() async {
    if (defaultCurrency.code == bitcoin.code) {
      updateCurrency(satoshi);
    } else if (defaultCurrency.code == satoshi.code) {
      updateCurrency(defaultFiatCurrency);
    } else {
      updateCurrency(bitcoin);
    }
  }

  updateCurrency(Currency newCurrency) async {
    if (newCurrency.code == bitcoin.code) {
      defaultCurrency = bitcoin;
    } else if (newCurrency.code == satoshi.code) {
      defaultCurrency = satoshi;
    } else {
      // if newCurrency is not bitcoin or satoshi, then fiat.
      defaultCurrency = newCurrency;
    }
    walletManager.setDefaultCurrency(widget.walletIndex, defaultCurrency);
  }
}
