import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class Transaction {
  // The transaction id (e.g. 78ff0d5baedbf6bb20ce71f...fad37).
  @HiveField(0)
  String transactionId;

  // The DateTime of the block transaction (2022-10-19 08:40:47).
  @HiveField(1)
  DateTime transactionBroadcast;

  // The number of blocks confirmations.
  @HiveField(2)
  int confirmations;

  // The The address and value of a transaction input (vin).
  @HiveField(3)
  List<Map> from;

  // The address and value of a transaction output (vout).
  @HiveField(4)
  List<Map> to;

  Transaction(
    this.transactionId,
    this.transactionBroadcast,
    this.confirmations,
    this.from,
    this.to,
  );
}
