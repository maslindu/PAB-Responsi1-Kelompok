import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment.dart';
import '../models/transaction.dart';

class OrderStatusScreen extends StatefulWidget {
  final Payment payment;
  final Transaction transaction;

  const OrderStatusScreen({
    Key? key, 
    required this.payment, 
    required this.transaction
  }) : super(key: key);

  @override
  _OrderStatusScreenState createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  late Timer _timer;
  String _currentStatus = '';
  late Box<Transaction> _transactionBox;
  late Box<String> _lastTransactionIdBox;

  @override
  void initState() {
    super.initState();
    _transactionBox = Hive.box<Transaction>('transactionBox');
    _lastTransactionIdBox = Hive.box<String>('lastTransactionIdBox');
    _currentStatus = widget.transaction.statusText;
    
    // Start listening for transaction updates
    _startStatusListener();
  }

  void _startStatusListener() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Get updated transaction from Hive
      final updatedTransaction = _transactionBox.get(widget.transaction.id);
      if (updatedTransaction != null && updatedTransaction.statusText != _currentStatus) {
        setState(() {
          _currentStatus = updatedTransaction.statusText;
        });
      }
      
      // Stop timer if order is completed or failed
      if (updatedTransaction?.status == 'completed' || updatedTransaction?.status == 'failed') {
        timer.cancel();
        if (updatedTransaction?.status == 'completed') {
          _showCompletionDialog();
        }
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Pesanan Selesai! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Terima kasih! Pesanan Anda telah berhasil diantar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear last transaction ID to hide notification
              _lastTransactionIdBox.delete('lastTransactionId');
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close order status screen
            },
            child: Text('Selesai'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    List<String> steps = [
      'Pembayaran Dikonfirmasi',
      'Makanan Sedang Disiapkan',
      'Makanan Sedang Diantar',
      'Makanan Sudah Sampai'
    ];

    int currentStep = steps.indexOf(_currentStatus);
    if (currentStep == -1) currentStep = 0; // Default to first step if not found

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: steps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value;
              bool isCompleted = index <= currentStep;
              bool isCurrent = index == currentStep;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? Colors.blue[700] : Colors.grey[700],
                        ),
                      ),
                    ),
                    if (isCurrent && index < steps.length - 1)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status Pesanan'),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: Colors.green,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Order #${widget.transaction.id.substring(widget.transaction.id.length - 6)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pembayaran berhasil dikonfirmasi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Progress Indicator
            _buildProgressIndicator(),

            SizedBox(height: 16),

            // Order Details
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Order Items
                  ...widget.transaction.items.map((cartItem) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                cartItem.menuItem.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItem.menuItem.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${cartItem.quantity}x',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${cartItem.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  Divider(height: 24),

                  // Display notes if available
                  if (widget.transaction.notes.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.transaction.notes,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                  ],
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${widget.payment.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Delivery Information
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Pengiriman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        widget.transaction.recipientName,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        widget.transaction.recipientPhone,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.transaction.deliveryAddress,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Payment Information
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Metode Pembayaran'),
                      Text(
                        widget.transaction.paymentMethod,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tanggal Pesanan'),
                      Text(
                        _formatDate(widget.transaction.createdAt),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status Pembayaran'),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.transaction.paymentMethod == 'Tunai' ? Colors.orange : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.transaction.paymentStatusText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}