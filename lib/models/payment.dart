import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 4)
class Payment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double totalAmount;

  @HiveField(2)
  String paymentMethod;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime expiresAt;

  @HiveField(5)
  String status; // 'pending', 'completed', 'expired'

  @HiveField(6)
  String? proofImagePath;

  @HiveField(7)
  String orderDetails;

  @HiveField(8)
  String transactionId; // New field to link to Transaction

  Payment({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    required this.expiresAt,
    this.status = 'pending',
    this.proofImagePath,
    required this.orderDetails,
    required this.transactionId, // Add to constructor
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }
}
