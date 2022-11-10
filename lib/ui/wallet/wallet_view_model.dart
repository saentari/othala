import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/address.dart';
import '../../models/simple_transaction.dart';
import '../../models/transaction.dart';
import '../../models/wallet.dart';

class WalletViewModel extends ChangeNotifier {
  late Wallet wallet;
  late double balance;
  late double amount;
  late List<SimpleTransaction> transactions;
  late int walletIndex;

  void initialise(BuildContext context) {
    walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    getWalletData(Hive.box('walletBox'), walletIndex);
    notifyListeners();
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

  showImage(BuildContext context, String path) {
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      return Image.asset(
        'assets/images/geran-de-klerk-qzgN45hseN0-unsplash.jpeg',
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
