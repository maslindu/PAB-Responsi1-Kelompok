import 'package:hive/hive.dart';

part 'address.g.dart';

@HiveType(typeId: 1)
class Address extends HiveObject {
  @HiveField(0)
  String label;

  @HiveField(1)
  String recipientName;

  @HiveField(2)
  String fullAddress;

  @HiveField(3)
  String phoneNumber;

  Address({
    required this.label,
    required this.recipientName,
    required this.fullAddress,
    required this.phoneNumber,
  });
}
