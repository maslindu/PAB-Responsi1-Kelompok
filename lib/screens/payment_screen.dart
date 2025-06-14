import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment.dart';
import '../models/transaction.dart';
import 'order_status_screen.dart'; // Import OrderStatusScreen

class PaymentScreen extends StatefulWidget {
  final Payment payment;
  final Transaction transaction;

  const PaymentScreen({
    Key? key, 
    required this.payment, 
    required this.transaction
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;
  File? _proofImage;
  bool _isProcessing = false;
  late Box<Transaction> _transactionBox;

  @override
  void initState() {
    super.initState();
    _transactionBox = Hive.box<Transaction>('transactionBox');
    
    // If payment method is cash, redirect immediately to OrderStatusScreen
    if (widget.payment.paymentMethod == 'Tunai') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderStatusScreen(
              payment: widget.payment,
              transaction: widget.transaction,
            ),
          ),
        );
      });
      return;
    }
    
    _updateRemainingTime();
    _startTimer();
    
    // Load existing proof image if available
    if (widget.payment.proofImagePath != null) {
      _proofImage = File(widget.payment.proofImagePath!);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateRemainingTime();
      if (_remainingTime.inSeconds <= 0) {
        _expirePayment();
        timer.cancel();
      }
    });
  }

  void _updateRemainingTime() {
    setState(() {
      _remainingTime = widget.payment.remainingTime;
    });
  }

  void _expirePayment() async {
    widget.payment.status = 'expired';
    await widget.payment.save();
    
    // Update transaction status to failed
    widget.transaction.status = 'failed';
    await _transactionBox.put(widget.transaction.id, widget.transaction);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Pembayaran Kedaluwarsa'),
        content: Text('Waktu pembayaran telah habis. Pesanan telah dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close payment screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProofImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final fileName = 'payment_proof_${widget.payment.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localImage = await File(pickedFile.path).copy('${appDocDir.path}/$fileName');

      setState(() {
        _proofImage = localImage;
      });

      // Update payment with proof image path
      widget.payment.proofImagePath = localImage.path;
      await widget.payment.save();

      // Update transaction with proof image
      widget.transaction.proofImagePath = localImage.path;
      await _transactionBox.put(widget.transaction.id, widget.transaction);
    }
  }

  Future<void> _completePayment() async {
    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan upload bukti pembayaran terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate processing time
    await Future.delayed(Duration(seconds: 2));

    widget.payment.status = 'completed';
    await widget.payment.save();

    // Update transaction status to paid
    widget.transaction.status = 'paid';
    await _transactionBox.put(widget.transaction.id, widget.transaction);

    setState(() {
      _isProcessing = false;
    });

    // Start order processing sequence
    _startOrderProcessing();

    // Navigate to OrderStatusScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderStatusScreen(
          payment: widget.payment,
          transaction: widget.transaction,
        ),
      ),
    );
  }

  void _startOrderProcessing() async {
    // Step 1: Payment confirmed (already done)
    // Step 2: Preparing (after 3 seconds)
    await Future.delayed(Duration(seconds: 3));
    widget.transaction.status = 'preparing';
    await _transactionBox.put(widget.transaction.id, widget.transaction);

    // Step 3: Delivering (after 30 seconds)
    await Future.delayed(Duration(seconds: 30));
    widget.transaction.status = 'delivering';
    await _transactionBox.put(widget.transaction.id, widget.transaction);

    // Step 4: Completed (after 1 minute)
    await Future.delayed(Duration(seconds: 60));
    widget.transaction.status = 'completed';
    widget.transaction.completedAt = DateTime.now();
    await _transactionBox.put(widget.transaction.id, widget.transaction);
  }

  void _copyAccountNumber() {
    Clipboard.setData(ClipboardData(text: '12324352'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor rekening berhasil disalin'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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
        title: Text('Pembayaran Transfer'),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _remainingTime.inMinutes < 2 ? Colors.red[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _remainingTime.inMinutes < 2 ? Colors.red : Colors.blue,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Batas Waktu Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _remainingTime.inMinutes < 2 ? Colors.red : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatTime(_remainingTime),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _remainingTime.inMinutes < 2 ? Colors.red : Colors.blue,
                    ),
                  ),
                  Text(
                    'menit tersisa',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Payment Details
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
                    'Detail Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pembayaran'),
                      Text(
                        'Rp ${widget.payment.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  Divider(height: 24),
                  
                  Text(
                    'Transfer ke Rekening:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bank BNI'),
                                Text(
                                  '12324352',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('a.n. Mas Muda'),
                              ],
                            ),
                            IconButton(
                              onPressed: _copyAccountNumber,
                              icon: Icon(Icons.copy),
                              tooltip: 'Salin nomor rekening',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Upload Proof Section
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
                    'Upload Bukti Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  if (_proofImage != null) ...[
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
                          _proofImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _pickProofImage,
                      icon: Icon(Icons.camera_alt),
                      label: Text(_proofImage != null ? 'Ganti Bukti Pembayaran' : 'Upload Bukti Pembayaran'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Complete Payment Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _remainingTime.inSeconds > 0 && !_isProcessing 
                  ? _completePayment 
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Memproses...'),
                      ],
                    )
                  : Text(
                      'Selesai Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),

            SizedBox(height: 16),

            // Instructions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber[700]),
                      SizedBox(width: 8),
                      Text(
                        'Petunjuk Pembayaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Transfer sesuai nominal yang tertera\n'
                    '2. Upload bukti transfer yang jelas\n'
                    '3. Pastikan nama pengirim sesuai dengan akun Anda\n'
                    '4. Setelah upload bukti, pesanan akan diproses otomatis',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}