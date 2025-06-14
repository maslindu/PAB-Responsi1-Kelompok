// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 5;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      items: (fields[1] as List).cast<CartItem>(),
      totalAmount: fields[2] as double,
      paymentMethod: fields[3] as String,
      createdAt: fields[4] as DateTime,
      status: fields[5] as String,
      proofImagePath: fields[6] as String?,
      deliveryAddress: fields[7] as String,
      recipientName: fields[8] as String,
      recipientPhone: fields[9] as String,
      completedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.paymentMethod)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.proofImagePath)
      ..writeByte(7)
      ..write(obj.deliveryAddress)
      ..writeByte(8)
      ..write(obj.recipientName)
      ..writeByte(9)
      ..write(obj.recipientPhone)
      ..writeByte(10)
      ..write(obj.completedAt);
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
