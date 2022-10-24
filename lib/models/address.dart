import 'package:hive/hive.dart';

import 'transaction.dart';

part 'address.g.dart';

@HiveType(typeId: 1)
class Address {
  // The address string (e.g. 'bc1q303hze33aay4s4m2qhq8vy0kaurq2990zhpfwc').
  @HiveField(0)
  final String address;

  // The raw transactions of the address.
  @HiveField(1)
  List<Transaction>? transactions;

  // The on-chain stats of the address.
  @HiveField(2)
  Map? chainStats;

  // The mempool stats of the address.
  @HiveField(3)
  Map? mempoolStats;

  // Total transaction balance of the address.
  num balance = 0;

  Address(
    this.address, {
    this.transactions,
    this.chainStats,
    this.mempoolStats,
  }) {
    balance = balanceTotal();
  }

  // Returns the blockchain [amount] denominated in bitcoin unit.
  num balanceConfirmed() {
    num funded = chainStats?['funded_txo_sum'] ?? 0;
    num spend = chainStats?['spent_txo_sum'] ?? 0;
    num amount = (funded - spend) / 100000000;
    return amount;
  }

  // Returns the mempool [amount] denominated in bitcoin unit.
  num balanceUnconfirmed() {
    num funded = mempoolStats?['funded_txo_sum'] ?? 0;
    num spend = mempoolStats?['spent_txo_sum'] ?? 0;
    num amount = (funded - spend) / 100000000;
    return amount;
  }

  // Returns the total [amount] denominated in bitcoin unit.
  num balanceTotal() {
    num confirmed = balanceConfirmed();
    num unconfirmed = balanceUnconfirmed();
    num amount = (confirmed + unconfirmed);
    return amount;
  }
}
