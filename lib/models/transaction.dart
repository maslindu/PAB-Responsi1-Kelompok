import 'package:hive/hive.dart';
import 'cart_item.dart';

part 'transaction.g.dart';

@HiveType(typeId: 5)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  List<CartItem> items;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  String paymentMethod;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String status; // 'pending', 'paid', 'preparing', 'delivering', 'completed', 'failed'

  @HiveField(6)
  String? proofImagePath;

  @HiveField(7)
  String deliveryAddress;

  @HiveField(8)
  String recipientName;

  @HiveField(9)
  String recipientPhone;

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  String notes; // Add notes field

  Transaction({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    this.status = 'pending',
    this.proofImagePath,
    required this.deliveryAddress,
    required this.recipientName,
    required this.recipientPhone,
    this.completedAt,
    this.notes = '', // Add notes parameter
  });

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Pembayaran Dikonfirmasi';
      case 'preparing':
        return 'Makanan Sedang Disiapkan';
      case 'delivering':
        return 'Makanan Sedang Diantar';
      case 'completed':
        return 'Pesanan Selesai';
      case 'failed':
        return 'Pesanan Gagal';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  String get paymentStatusText {
    if (paymentMethod == 'Tunai') {
      return 'COD (Cash on Delivery)';
    } else {
      return 'Lunas';
    }
  }

  bool get isActive => ['pending', 'paid', 'preparing', 'delivering'].contains(status);
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}