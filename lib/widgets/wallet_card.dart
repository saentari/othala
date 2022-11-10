import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/address.dart';
import '../models/wallet.dart';
import '../themes/theme_data.dart';
import '../ui/receive_payment/receive_payment_view.dart';
import '../ui/send_payment/send_payment_view.dart';
import 'flat_button.dart';

class WalletCard extends StatefulWidget {
  const WalletCard(this.walletIndex, {Key? key}) : super(key: key);

  final int walletIndex;

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  late Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: Hive.box('walletBox').listenable(),
          builder: (context, Box box, widget2) {
            wallet = box.getAt(widget.walletIndex);
            return Scaffold(
              body: Stack(
                fit: StackFit.loose,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
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
                  ),
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: 0.0,
                    child: Row(
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
                                        SendPaymentView(widget.walletIndex),
                                  ),
                                );
                              },
                              child: const CustomFlatButton(textLabel: 'Send'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      ReceivePaymentView(wallet),
                                ),
                              );
                            },
                            child: const CustomFlatButton(
                              textLabel: 'Receive',
                              buttonColor: customDarkBackground,
                              fontColor: customWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
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

  // Loads the stored image or reverts back to the default image.
  showImage() {
    if (FileSystemEntity.typeSync(wallet.imagePath) ==
        FileSystemEntityType.notFound) {
      return Image.asset(
        'assets/images/geran-de-klerk-qzgN45hseN0-unsplash.jpeg',
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(wallet.imagePath),
        fit: BoxFit.cover,
      );
    }
  }
}
