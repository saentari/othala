import 'package:hive/hive.dart';

import '../models/currency.dart';
import '../models/transaction.dart';

part 'wallet.g.dart';

@HiveType(typeId: 0)
class Wallet {
  @HiveField(0)
  String key;
  @HiveField(1)
  String name;
  @HiveField(2)
  String type;
  @HiveField(3)
  String network;
  @HiveField(4)
  List<String> address;
  @HiveField(5)
  List<num> balance;
  @HiveField(6)
  List<Transaction> transactions;
  @HiveField(7)
  String imageId;
  @HiveField(8)
  String imagePath;
  @HiveField(9)
  Currency defaultFiatCurrency;
  @HiveField(10)
  Currency defaultCurrency;

  Wallet(
    this.key,
    this.name,
    this.type,
    this.network,
    this.address,
    this.balance,
    this.transactions,
    this.imageId,
    this.imagePath,
    this.defaultFiatCurrency,
    this.defaultCurrency,
  );
}
