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
  late Wallet wallet;
  late double balance;
  late double amount;
  late List<SimpleTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    return ValueListenableBuilder(
      valueListenable: Hive.box('walletBox').listenable(),
      builder: (context, Box box, widget) {
        getWalletData(box, walletIndex);
        return SafeAreaX(
          appBar: AppBar(
            centerTitle: true,
            title: titleIcon,
            backgroundColor: customBlack,
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
                      child: showImage(wallet.imagePath),
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
                          wallet.name,
                          style: const TextStyle(
                            color: customWhite,
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
                              amount: amount,
                              decimalDigits: 8,
                              symbol: unicodeBitcoin),
                          style: const TextStyle(
                            color: customWhite,
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
                              currency: wallet.defaultFiatCurrency,
                              amount: balance),
                          style: const TextStyle(
                            color: customWhite,
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
                  color: customBlack,
                  backgroundColor: customYellow,
                  onRefresh: () async {
                    final wm = WalletManager();
                    await wm.setTransactions(walletIndex);
                  },
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const ListDivider(),
                    itemCount: transactions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListItemTransaction(
                        transactions[index].address,
                        subtitle: transactions[index].dateTime,
                        value: transactions[index].amount,
                        subtitleValue: transactions[index].confirmations,
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
                        buttonColor: customDarkBackground,
                        fontColor: customWhite,
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

  Future<void> getWalletData(Box<dynamic> box, walletIndex) async {
    if (walletIndex < box.length) {
      wallet = box.getAt(walletIndex);
    }

    // Balance
    amount = 0;
    for (Address addressObj in wallet.addresses) {
      amount = amount + addressObj.balance;
    }
    balance = amount * wallet.defaultFiatCurrency.priceUsd;

    // Transactions
    transactions = [];
    for (Address addressObj in wallet.addresses) {
      for (Transaction tx in addressObj.transactions ?? []) {
        transactions.add(SimpleTransaction(addressObj.address, tx));
      }
    }
    // Sort transactions by date/time
    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  showImage(String path) {
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

    List ioAmount = checkInputOutput(transaction, address);
    address = ioAmount.elementAt(0);
    amount = ioAmount.elementAt(1);

    int blockConf = transaction.confirmations;
    if (blockConf == 0) {
      confirmations = 'pending';
    } else if (blockConf < 6) {
      confirmations = '$blockConf conf.';
    }
  }

  List checkInputOutput(Transaction transaction, String address) {
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
      // Ignore empty OP_RETURN entries.
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
}
