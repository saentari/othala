import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/address.dart';
import '../../models/simple_transaction.dart';
import '../../models/transaction.dart';
import '../../models/wallet.dart';

class SendPaymentUtxoViewModel extends ChangeNotifier {
  late Wallet wallet;
  late double balance;
  late double amount;
  late List<SimpleTransaction> transactions;
  late int walletIndex;
  var utxoPicking = true;

  void initialise(BuildContext context, int walletIndex) {
    this.walletIndex = walletIndex;
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
}
