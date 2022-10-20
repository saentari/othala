import 'package:hive/hive.dart';

import 'address.dart';
import 'currency.dart';
import 'transaction.dart';

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
  String derivationPath;
  @HiveField(4)
  List<Address> addresses;
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
    this.derivationPath,
    this.addresses,
    this.balance,
    this.transactions,
    this.imageId,
    this.imagePath,
    this.defaultFiatCurrency,
    this.defaultCurrency,
  );
}
