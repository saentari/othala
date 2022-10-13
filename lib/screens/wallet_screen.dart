import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/currency.dart';
import '../models/transaction.dart';
import '../models/unsplash_image.dart';
import '../models/wallet.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';
import '../widgets/list_item_transaction.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  /// Stores the current page index for the api requests.
  int page = 0, totalPages = -1;

  /// Stores the currently loaded loaded images.
  List<UnsplashImage> images = [];

  /// States whether there is currently a task running loading images.
  bool loadingImages = false;

  /// Stored the currently searched keyword.
  late String keyword;

  final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));
  num _balance = 0.0;
  num _amount = 0.0;

  late Wallet _wallet;

  @override
  Widget build(BuildContext context) {
    final walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    _getTransactions(walletIndex);
    return Container(
      color: kDarkBackgroundColor,
      child: SafeArea(
        child: ValueListenableBuilder(
            valueListenable: Hive.box('walletBox').listenable(),
            builder: (context, Box box, widget2) {
              _updateValues(box, walletIndex);
              return Scaffold(
                body: Container(
                  padding: const EdgeInsets.only(
                    bottom: 16.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Hero(
                            tag: 'imageHero',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: _showImage(_wallet.imagePath),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/wallet_settings_screen',
                                  arguments: walletIndex,
                                );
                              },
                              icon: const Icon(Icons.more_vert),
                            ),
                          ),
                          Positioned(
                            top: 20.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _wallet.name,
                                  style: const TextStyle(
                                    color: kWhiteColor,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 60.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  getNumberFormat(
                                      currency: Currency('BTC'),
                                      amount: _amount,
                                      decimalDigits: 8,
                                      symbol: unicodeBitcoin),
                                  style: const TextStyle(
                                    color: kWhiteColor,
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 110.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  getNumberFormat(
                                      currency: _wallet.defaultFiatCurrency,
                                      amount: _balance),
                                  style: const TextStyle(
                                    color: kWhiteColor,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      Expanded(
                        child: RefreshIndicator(
                          color: kBlackColor,
                          backgroundColor: kYellowColor,
                          onRefresh: () async {
                            await _getTransactions(walletIndex);
                          },
                          child: ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const ListDivider(),
                            itemCount: _wallet.transactions.length,
                            itemBuilder: (BuildContext context, int index) {
                              String formattedDateTime =
                                  DateFormat('yyyy-MM-dd kk:mm').format(_wallet
                                      .transactions[index]
                                      .transactionBroadcast);
                              double amount = 0.0;
                              String address = '';
                              List ioAmount = _checkInputOutput(
                                  _wallet.transactions[index],
                                  _wallet.address.first);
                              address = ioAmount.elementAt(0);
                              amount = ioAmount.elementAt(1);
                              String confirmations = '';
                              int blockConf =
                                  _wallet.transactions[index].confirmations;
                              if (blockConf == 0) {
                                confirmations = 'pending';
                              } else if (blockConf < 6) {
                                confirmations = '$blockConf conf.';
                              }
                              return ListItemTransaction(
                                address,
                                subtitle: formattedDateTime,
                                value: amount,
                                subtitleValue: confirmations,
                              );
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const CustomFlatButton(
                                textLabel: 'Cancel',
                                buttonColor: kDarkBackgroundColor,
                                fontColor: kWhiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future<void> _updateValues(Box<dynamic> box, walletIndex) async {
    if (walletIndex < box.length) {
      _wallet = box.getAt(walletIndex);
    }
    _amount = _wallet.balance.first;
    _balance = _amount * _wallet.defaultFiatCurrency.priceUsd;
  }

  List _checkInputOutput(Transaction transaction, String address) {
    bool sender = false;
    bool receiver = false;
    double vinAmount = 0.0;
    double voutAmount = 0.0;
    String recipient = '';

    for (Map vin in transaction.from) {
      if (vin.values.elementAt(0).toString().toLowerCase() ==
          address.toLowerCase()) {
        sender = true;
        vinAmount = vinAmount + vin.values.elementAt(1);
      }
    }

    for (Map vout in transaction.to) {
      if (sender == false &&
          vout.values.elementAt(0).toString().toLowerCase() ==
              address.toLowerCase()) {
        recipient = vout.values.elementAt(0);
        voutAmount = vout.values.elementAt(1);
        break;
      }
      // Ignore empty OP_RETURN entries
      if (vout.values.elementAt(0) != '' &&
          vout.values.elementAt(0).toString().toLowerCase() !=
              address.toLowerCase()) {
        recipient = vout.values.elementAt(0);
        voutAmount = voutAmount - vout.values.elementAt(1);
      } else {
        receiver = true;
      }
    }

    // Use tx outputs of sender instead of tx input of receiver
    if (sender == true && receiver == false) {
      voutAmount = 0 - vinAmount;
    }

    List ioAmount = [recipient, voutAmount];
    return ioAmount;
  }

  Future<void> _getTransactions(int index) async {
    bool isSynced = await _walletManager.isSynced(index);
    if (isSynced == false) {
      await _walletManager.updateBalance(index);
      await _walletManager.updateTransactions(index);
    }
  }

  _showImage(String path) {
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      return Image.asset(
        'assets/images/andreas-gucklhorn-mawU2PoJWfU-unsplash.jpeg',
        fit: BoxFit.cover,
        color: Colors.white.withOpacity(0.8),
        colorBlendMode: BlendMode.modulate,
        height: 160,
        width: MediaQuery.of(context).size.width,
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        color: Colors.white.withOpacity(0.8),
        colorBlendMode: BlendMode.modulate,
        height: 160,
        width: MediaQuery.of(context).size.width,
      );
    }
  }
}
