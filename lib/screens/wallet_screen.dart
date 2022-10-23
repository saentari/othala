import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart';
import '../models/address.dart';
import '../models/currency.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../utils/utils.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';
import '../widgets/list_item_transaction.dart';
import '../widgets/safe_area.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  final Box box = Hive.box('walletBox');
  late Wallet _wallet;
  late double _balance;
  late double _amount;
  late List<SimpleTransaction> _transactions;

  @override
  Widget build(BuildContext context) {
    final walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, widget) {
        _getWalletData(box, walletIndex);
        return SafeAreaX(
          appBar: AppBar(
            centerTitle: true,
            title: titleIcon,
            backgroundColor: kBlackColor,
            automaticallyImplyLeading: false,
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
                    final wm = WalletManager(box);
                    await wm.setTransactions(walletIndex);
                  },
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const ListDivider(),
                    itemCount: _transactions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListItemTransaction(
                        _transactions[index].address,
                        subtitle: _transactions[index].dateTime,
                        value: _transactions[index].amount,
                        subtitleValue: _transactions[index].confirmations,
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
        );
      },
    );
  }

  Future<void> _getWalletData(Box<dynamic> box, walletIndex) async {
    if (walletIndex < box.length) {
      _wallet = box.getAt(walletIndex);
    }

    // Balance
    _amount = 0;
    for (Address addressObj in _wallet.addresses) {
      _amount = _amount + addressObj.balance;
    }
    _balance = _amount * _wallet.defaultFiatCurrency.priceUsd;

    // Transactions
    _transactions = [];
    for (Address addressObj in _wallet.addresses) {
      for (Transaction tx in addressObj.transactions ?? []) {
        _transactions.add(SimpleTransaction(addressObj.address, tx));
      }
    }
    // Sort transactions by date/time
    _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
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
