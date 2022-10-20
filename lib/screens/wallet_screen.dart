import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/address.dart';
import '../models/currency.dart';
import '../models/derivation_path.dart';
import '../models/transaction.dart';
import '../models/unsplash_image.dart';
import '../models/wallet.dart';
import '../services/bitcoin_client.dart';
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
  List<SimpleTransaction> simpleTx = [];

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
              _updateBalance(box, walletIndex);
              simpleTransactionBuilder();
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
                            itemCount: simpleTx.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListItemTransaction(
                                simpleTx[index].address,
                                subtitle: simpleTx[index].dateTime,
                                value: simpleTx[index].amount,
                                subtitleValue: simpleTx[index].confirmations,
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

  Future<void> _updateBalance(Box<dynamic> box, walletIndex) async {
    if (walletIndex < box.length) {
      _wallet = box.getAt(walletIndex);
    }
    _amount = 0;
    for (Address addressObj in _wallet.addresses) {
      _amount = _amount + addressObj.balance;
    }
    _balance = _amount * _wallet.defaultFiatCurrency.priceUsd;
  }

  simpleTransactionBuilder() {
    simpleTx = [];
    for (Address addressObj in _wallet.addresses) {
      for (Transaction tx in addressObj.transactions ?? []) {
        simpleTx.add(SimpleTransaction(addressObj.address, tx));
      }
    }
    // Sort transactions by date/time
    simpleTx.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Future<void> _getTransactions(int walletIndex) async {
    Box box = Hive.box('walletBox');

    Wallet wallet = box.getAt(walletIndex);
    String derivationPath = wallet.derivationPath;
    final dp = DerivationPath(derivationPath);
    dp.setAddressIndex(0);
    final seed = await _walletManager.getWalletSeed(walletIndex);
    final bitcoinClient = BitcoinClient(seed);
    bool hasTxHistory = true;
    List<Address> addresses = [];

    while (hasTxHistory) {
      bitcoinClient.setDerivationPath(derivationPath);
      String address = bitcoinClient.getAddress(dp.addressIndex);
      var data = await bitcoinClient.getTransactionAddressStats(address);

      Map chainStats = data['chain_stats'];
      Map mempoolStats = data['mempool_stats'];
      mempoolStats = data['mempool_stats'];
      Address addressObj =
          Address(address, chainStats: chainStats, mempoolStats: mempoolStats);
      addresses.add(addressObj);
      final txCount = chainStats['tx_count'] + mempoolStats['tx_count'];
      if (txCount > 0) {
        dp.addressIndex = dp.addressIndex + 1;
      } else {
        hasTxHistory = false;
        bitcoinClient.address = bitcoinClient.getAddress(dp.addressIndex);
      }
    }
    dp.setAddressIndex(dp.addressIndex + 1);

    wallet.derivationPath = dp.derivationPath;
    wallet.addresses = addresses;
    box.putAt(walletIndex, wallet);

    await _walletManager.updateTransactions(walletIndex);

    // bool isSynced = await _walletManager.isSynced(walletIndex);
    // if (isSynced == false) {
    //   // await _walletManager.updateBalance(walletIndex);
    //   await _walletManager.updateTransactions(walletIndex);
    // }
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

class SimpleTransaction {
  String address;
  Transaction transaction;

  double amount = 0.0;
  String dateTime = '';
  String confirmations = '';

  SimpleTransaction(this.address, this.transaction) {
    dateTime =
        DateFormat('yyyy-MM-dd kk:mm').format(transaction.transactionBroadcast);

    List ioAmount = _checkInputOutput(transaction, address);
    address = ioAmount.elementAt(0);
    amount = ioAmount.elementAt(1);

    int blockConf = transaction.confirmations;
    if (blockConf == 0) {
      confirmations = 'pending';
    } else if (blockConf < 6) {
      confirmations = '$blockConf conf.';
    }
  }
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
