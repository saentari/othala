import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction {
  @HiveField(0)
  String transactionId;
  @HiveField(1)
  DateTime transactionBroadcast;
  @HiveField(2)
  int confirmations;
  @HiveField(3)
  List<Map> from;
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
