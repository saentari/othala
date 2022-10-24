import 'package:hive/hive.dart';

import 'address.dart';
import 'currency.dart';

part 'wallet.g.dart';

@HiveType(typeId: 0)
class Wallet {
  // The uniquely generated id for the [Wallet].
  @HiveField(0)
  String key;

  // Customizable name given to the [Wallet].
  @HiveField(1)
  String name;

  // Read-only `address` wallet or full `mnemonic` wallet type.
  @HiveField(2)
  String type;

  // Generates addresses and sets the network.
  @HiveField(3)
  String derivationPath;

  // Stores [Address] data such as transactions and balances.
  @HiveField(4)
  List<Address> addresses;

  // The unique id for the background image.
  @HiveField(5)
  String imageId;

  // The file path where the background image is stored.
  @HiveField(6)
  String imagePath;

  // The preferred fiat currency: default `USD`.
  @HiveField(7)
  Currency defaultFiatCurrency;

  // The preferred value denominator: default `BTC`.
  @HiveField(8)
  Currency defaultCurrency;

  Wallet(
    this.key,
    this.name,
    this.type,
    this.derivationPath,
    this.addresses,
    this.imageId,
    this.imagePath,
    this.defaultFiatCurrency,
    this.defaultCurrency,
  );
}
