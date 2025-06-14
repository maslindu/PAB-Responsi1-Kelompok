import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/address.dart';
import '../viewmodels/menu_view_model.dart';
import 'sliding_sidebar.dart';
import 'address_list_screen.dart';
import '../models/payment.dart';
import '../models/transaction.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final MenuViewModel viewModel;

  const CheckoutScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int _selectedIndex = 1;
  late Box<Address> _addressBox;
  late Box<int> _selectedAddressIndexBox;
  late Box<String> _lastTransactionIdBox;
  String _selectedPaymentMethod = 'Transfer';

  @override
  void initState() {
    super.initState();
    _addressBox = Hive.box<Address>('addresses');
    _selectedAddressIndexBox = Hive.box<int>('selectedAddressIndexBox');
    _lastTransactionIdBox = Hive.box<String>('lastTransactionIdBox');
    _notesController.text = widget.viewModel.notes;
    _notesController.addListener(() {
      widget.viewModel.setNotes(_notesController.text);
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showSlidingSidebar() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Material(
          type: MaterialType.transparency,
          child: const SlidingSidebar(),
        );
      },
    );
  }

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambahkan Catatan'),
          content: TextField(
            controller: _notesController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Masukkan catatan Anda di sini...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.viewModel.setNotes(_notesController.text);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.payment),
                title: const Text('Transfer'),
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'Transfer';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.money),
                title: const Text('Tunai'),
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'Tunai';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyPromoCode() {
    if (_promoController.text.isNotEmpty) {
      final result = widget.viewModel.applyPromoCode(_promoController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: result.contains('berhasil') ? Colors.green : Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      
      if (result.contains('berhasil')) {
        _promoController.clear();
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      _showSlidingSidebar();
    }
  }

  void _onConfirmOrder() async {
    // Get selected address
    final selectedIndex = _selectedAddressIndexBox.get('selected');
    final selectedAddress = selectedIndex != null && _addressBox.isNotEmpty
        ? _addressBox.getAt(selectedIndex)
        : null;

    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan pilih alamat pengiriman terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create transaction record with notes
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
    final transaction = Transaction(
      id: transactionId,
      items: List.from(widget.viewModel.cartItems), // Copy cart items
      totalAmount: widget.viewModel.total,
      paymentMethod: _selectedPaymentMethod,
      createdAt: DateTime.now(),
      status: _selectedPaymentMethod == 'Transfer' ? 'pending' : 'paid',
      deliveryAddress: selectedAddress.fullAddress,
      recipientName: selectedAddress.recipientName,
      recipientPhone: selectedAddress.phoneNumber,
      notes: widget.viewModel.notes, // Include notes from view model
    );

    // Save transaction
    final transactionBox = Hive.box<Transaction>('transactionBox');
    await transactionBox.put(transaction.id, transaction);
    await _lastTransactionIdBox.put('lastTransactionId', transaction.id);

    if (_selectedPaymentMethod == 'Transfer') {
      // Create payment record
      final payment = Payment(
        id: transactionId,
        totalAmount: widget.viewModel.total,
        paymentMethod: _selectedPaymentMethod,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        orderDetails: _buildOrderDetails(),
        transactionId: transactionId,
      );
      
      // Save to Hive
      final paymentBox = Hive.box<Payment>('paymentBox');
      await paymentBox.put(payment.id, payment);
      
      // Clear cart immediately after creating transaction
      widget.viewModel.clearCart();
      
      // Navigate to payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            payment: payment,
            transaction: transaction,
          ),
        ),
      ).then((_) {
        Navigator.pop(context);
      });
    } else {
      // For cash payment, create a payment record with 'paid' status
      final payment = Payment(
        id: transactionId,
        totalAmount: widget.viewModel.total,
        paymentMethod: _selectedPaymentMethod,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now(),
        orderDetails: _buildOrderDetails(),
        transactionId: transactionId,
        status: 'paid',
      );

      final paymentBox = Hive.box<Payment>('paymentBox');
      await paymentBox.put(payment.id, payment);

      // Start order processing immediately
      _startOrderProcessing(transaction);
      
      // Clear cart
      widget.viewModel.clearCart();
      
      // Navigate to PaymentScreen to show details and then pop back
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            payment: payment,
            transaction: transaction,
          ),
        ),
      ).then((_) {
        Navigator.pop(context);
      });
    }
  }

  void _startOrderProcessing(Transaction transaction) async {
    final transactionBox = Hive.box<Transaction>('transactionBox');
    
    // Update status to preparing after 7 seconds
    Future.delayed(Duration(seconds: 7), () async {
      transaction.status = 'preparing';
      await transactionBox.put(transaction.id, transaction);
    });

    // Update status to delivering after 15 seconds (7 + 15 = 22 seconds total)
    Future.delayed(Duration(seconds: 22), () async {
      transaction.status = 'delivering';
      await transactionBox.put(transaction.id, transaction);
    });

    // Update status to completed after 15 more seconds (7 + 15 + 15 = 37 seconds total)
    Future.delayed(Duration(seconds: 37), () async {
      transaction.status = 'completed';
      transaction.completedAt = DateTime.now();
      await transactionBox.put(transaction.id, transaction);
    });
  }

  String _buildOrderDetails() {
    String details = 'Pesanan:\n';
    for (var item in widget.viewModel.cartItems) {
      details += '${item.menuItem.name} x${item.quantity} = Rp ${item.totalPrice.toStringAsFixed(0)}\n';
    }
    details += '\nSubtotal: Rp ${widget.viewModel.subtotal.toStringAsFixed(0)}';
    details += '\nOngkir: Rp ${widget.viewModel.shippingCost.toStringAsFixed(0)}';
    details += '\nBiaya Admin: Rp ${widget.viewModel.adminFee.toStringAsFixed(0)}';
    
    // Add discount info if applied
    if (widget.viewModel.isPromoApplied) {
      details += '\nDiskon (${widget.viewModel.promoCode}): -Rp ${widget.viewModel.discountAmount.toStringAsFixed(0)}';
    }
    
    details += '\nTotal: Rp ${widget.viewModel.total.toStringAsFixed(0)}';
    return details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Address Section
                    ValueListenableBuilder<Box<int>>(
                      valueListenable: _selectedAddressIndexBox.listenable(),
                      builder: (context, box, _) {
                        final selectedIndex = box.get('selected');
                        final selectedAddress = selectedIndex != null && _addressBox.isNotEmpty
                            ? _addressBox.getAt(selectedIndex)
                            : null;

                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(254, 216, 102, 1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.black),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedAddress?.recipientName ?? 'Nama Penerima',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(selectedAddress?.fullAddress ?? 'Alamat penerima'),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddressListScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Text(
                                    'Ganti Alamat',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16),

                    // Order Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pesanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Cart Items
                          AnimatedBuilder(
                            animation: widget.viewModel,
                            builder: (context, child) {
                              if (widget.viewModel.cartItems.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Text(
                                      'Keranjang kosong',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: widget.viewModel.cartItems.map((cartItem) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      children: [
                                        // Product Image
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.asset(
                                              cartItem.menuItem.image,
                                              width: 150,
                                              height: 150,
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

                                        // Product Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cartItem.menuItem.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'Description',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  // Decrease button
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        widget.viewModel.updateCartItemQuantity(
                                                          cartItem.menuItem.id,
                                                          cartItem.quantity - 1,
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),

                                                  Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 8),
                                                    child: Text(
                                                      cartItem.quantity.toString(),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),

                                                  // Increase button
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        widget.viewModel.updateCartItemQuantity(
                                                          cartItem.menuItem.id,
                                                          cartItem.quantity + 1,
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(width: 8),
                                                  
                                                  // Delete button
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        widget.viewModel.removeFromCart(cartItem.menuItem.id);
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),

                                                  Spacer(),

                                                  // Price
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Rp ${cartItem.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          Divider(),

                          // Notes Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AnimatedBuilder(
                                animation: widget.viewModel,
                                builder: (context, child) {
                                  return Text(
                                    'Total : Rp ${widget.viewModel.subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: _showNotesDialog,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.note_add, size: 16),
                                      SizedBox(width: 4),
                                      Text('Catatan'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Payment Method Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Metode Pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _showPaymentMethodDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _selectedPaymentMethod,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Payment Details
                          AnimatedBuilder(
                            animation: widget.viewModel,
                            builder: (context, child) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Subtotal'),
                                      Text(
                                        'Rp ${widget.viewModel.subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ongkir'),
                                      Text(
                                        'Rp ${widget.viewModel.shippingCost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Biaya Admin'),
                                      Text(
                                        'Rp ${widget.viewModel.adminFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                      ),
                                    ],
                                  ),
                                  
                                  // Show discount if applied
                                  if (widget.viewModel.isPromoApplied) ...[
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Diskon (${widget.viewModel.promoCode})',
                                              style: TextStyle(color: Colors.green[700]),
                                            ),
                                            SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                widget.viewModel.removePromoCode();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Kode promo dihapus'),
                                                    backgroundColor: Colors.orange,
                                                  ),
                                                );
                                              },
                                              child: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '-Rp ${widget.viewModel.discountAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                          style: TextStyle(color: Colors.green[700]),
                                        ),
                                      ],
                                    ),
                                  ],
                                  
                                  Divider(height: 24),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${widget.viewModel.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),

                          SizedBox(height: 16),

                          // Promo Code Section
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Kode Promo',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _applyPromoCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Terapkan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Confirm Order Button
            Container(
              padding: EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: widget.viewModel,
                builder: (context, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ValueListenableBuilder<Box<int>>(
                      valueListenable: _selectedAddressIndexBox.listenable(),
                      builder: (context, box, _) {
                        final selectedIndex = box.get('selected');
                        final selectedAddress = selectedIndex != null && _addressBox.isNotEmpty
                            ? _addressBox.getAt(selectedIndex)
                            : null;

                        final bool isAddressValid = selectedAddress != null &&
                            selectedAddress.recipientName.isNotEmpty &&
                            selectedAddress.fullAddress.isNotEmpty;

                        return ElevatedButton(
                          onPressed: widget.viewModel.cartItems.isNotEmpty && isAddressValid
                              ? _onConfirmOrder
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE53E3E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: Text(
                            'Konfirmasi Pesanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}