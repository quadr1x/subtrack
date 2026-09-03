// GENERATED CODE - DO NOT MODIFY BY HAND
// Manual implementation of Hive TypeAdapter for Subscription.

part of 'subscription.dart';

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 0;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
      currency: fields[3] as String,
      category: fields[4] as String,
      description: fields[5] as String?,
      logoUrl: fields[6] as String?,
      color: fields[7] as String?,
      nextPaymentDate: fields[8] as DateTime,
      paymentMethod: fields[9] as String,
      billingCycle: fields[10] as String,
      startDate: fields[11] as DateTime?,
      endDate: fields[12] as DateTime?,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.logoUrl)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.nextPaymentDate)
      ..writeByte(9)
      ..write(obj.paymentMethod)
      ..writeByte(10)
      ..write(obj.billingCycle)
      ..writeByte(11)
      ..write(obj.startDate)
      ..writeByte(12)
      ..write(obj.endDate)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
