import 'package:hive/hive.dart';

part 'currency.g.dart';

@HiveType(typeId: 3)
class Currency {
  // The id of the currency (e.g. 'USD').
  @HiveField(0)
  final String code;

  // The code of the currency (e.g. 'usd-us-dollars').
  @HiveField(1)
  final String id;

  // The name of the currency. (e.g. US dollar)
  @HiveField(2)
  final String name;

  // The currency symbol (e.g. $)
  @HiveField(3)
  final String symbol;

  // The locale of the currency. (e.g. en_US)
  @HiveField(4)
  final String locale;

  @HiveField(5)
  // The USD price of the currency. (e.g. 0.88321)
  double priceUsd;

  Currency(
    this.code, {
    this.id = 'usd-us-dollars',
    this.name = 'US dollar',
    this.symbol = r'$',
    this.locale = 'en_US',
    this.priceUsd = 1.0,
  });
}
