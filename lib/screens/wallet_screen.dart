import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../models/unsplash_image.dart';
import '../models/wallet.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';
import '../widgets/list_item_transaction.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  /// Stores the current page index for the api requests.
  int page = 0, totalPages = -1;

  /// Stores the currently loaded loaded images.
  List<UnsplashImage> images = [];

  /// States whether there is currently a task running loading images.
  bool loadingImages = false;

  /// Stored the currently searched keyword.
  late String keyword;

  final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));
  var _format = NumberFormat("0.########", "en_US");
  num _balance = 0.0;

  late Wallet _wallet;

  @override
  Widget build(BuildContext context) {
    final _walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    _getTransactions(_walletIndex);
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: Hive.box('walletBox').listenable(),
          builder: (context, Box box, widget2) {
            _updateValues(box, _walletIndex);
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
                                arguments: _walletIndex,
                              );
                            },
                            icon: const Icon(Icons.more_vert),
                          ),
                        ),
                        Positioned(
                          top: 40.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _format.format(_balance),
                                style: const TextStyle(
                                  color: kWhiteColor,
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                _wallet.defaultCurrency.code,
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
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const ListDivider(),
                        itemCount: _wallet.transactions.length,
                        itemBuilder: (BuildContext context, int index) {
                          String _formattedDateTime =
                              DateFormat('yyyy-MM-dd kk:mm').format(_wallet
                                  .transactions[index].transactionBroadcast);
                          double _amount = 0.0;
                          String _address = '';
                          List _ioAmount = _checkInputOutput(
                              _wallet.transactions[index],
                              _wallet.address.first);
                          _address = _ioAmount.elementAt(0);
                          _amount = _ioAmount.elementAt(1);
                          return ListItemTransaction(
                            _address,
                            subtitle: _formattedDateTime,
                            value: _amount,
                          );
                        },
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
    );
  }

  Future<void> _updateValues(Box<dynamic> box, walletIndex) async {
    if (walletIndex < box.length) {
      _wallet = box.getAt(walletIndex);
    }
    num _amount = _wallet.balance.first;
    _balance = _amount * _wallet.defaultCurrency.priceUsd;
    if (_wallet.defaultCurrency.code != 'BTC' &&
        _wallet.defaultCurrency.code != 'SATS') {
      _format = NumberFormat.simpleCurrency(name: _wallet.defaultCurrency.code);
    }
  }

  List _checkInputOutput(Transaction transaction, String address) {
    double _amount = 0.0;
    String _io = '';
    for (Map vin in transaction.from) {
      if (vin.values.first == address) {
        // Filter out transactions to self
        for (Map vout in transaction.to) {
          _io = address;
          if (vout.values.first != address) {
            _amount = _amount - vout.values.elementAt(1);
            _io = vout.values.elementAt(0);
          }
          break;
        }
        break;
      } else {
        // 100% new deposit to address
        for (Map vout in transaction.to) {
          String _address = address;
          if (vout.values.first == _address) {
            _amount = _amount + vout.values.elementAt(1);
            _io = vout.values.elementAt(0);
          }
        }
        break;
      }
    }
    List _ioAmount = [_io, _amount];
    return _ioAmount;
  }

  Future<void> _getTransactions(int index) async {
    await _walletManager.updateBalance(index);
    await _walletManager.updateTransactions(index);
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
