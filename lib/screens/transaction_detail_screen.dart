// lib/screens/transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(transaction.status),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(transaction.status),
                    color: _getStatusColor(transaction.status),
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order #${transaction.id.substring(transaction.id.length - 6)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Order Items
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...transaction.items.map((cartItem) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItem.menuItem.name,
                                  style: const TextStyle(
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  const Divider(height: 24),

                  // Display notes if available
                  if (transaction.notes.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            transaction.notes,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                  ],
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${transaction.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
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

            const SizedBox(height: 16),

            // Delivery Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Pengiriman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        transaction.recipientName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        transaction.recipientPhone,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          transaction.deliveryAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Payment Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Metode Pembayaran'),
                      Text(
                        transaction.paymentMethod,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status Pembayaran'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: transaction.paymentMethod == 'Tunai' ? Colors.orange : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transaction.paymentStatusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tanggal Pesanan'),
                      Text(
                        _formatDate(transaction.createdAt),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (transaction.completedAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tanggal Selesai'),
                        Text(
                          _formatDate(transaction.completedAt!),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Proof of Payment (if available)
            if (transaction.proofImagePath != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bukti Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(transaction.proofImagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Text(
                                  'Gambar tidak dapat dimuat',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'delivering':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'paid':
        return Icons.payment;
      case 'preparing':
        return Icons.restaurant;
      case 'delivering':
        return Icons.delivery_dining;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}