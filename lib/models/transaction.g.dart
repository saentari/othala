// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 1;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      fields[0] as String,
      fields[1] as DateTime,
      fields[2] as int,
      (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.transactionId)
      ..writeByte(1)
      ..write(obj.transactionBroadcast)
      ..writeByte(2)
      ..write(obj.confirmations)
      ..writeByte(3)
      ..write(obj.from)
      ..writeByte(4)
      ..write(obj.to);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
