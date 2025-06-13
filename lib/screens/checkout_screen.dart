import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/address.dart';
import '../viewmodels/menu_view_model.dart';
import 'sliding_sidebar.dart'; // Import SlidingSidebar
import 'address_list_screen.dart'; // Import AddressListScreen

class CheckoutScreen extends StatefulWidget {
  final MenuViewModel viewModel;

  const CheckoutScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _promoController = TextEditingController();
  int _selectedIndex = 1; // Cart tab selected
  late Box<Address> _addressBox;
  late Box<int> _selectedAddressIndexBox;

  @override
  void initState() {
    super.initState();
    _addressBox = Hive.box<Address>('addresses');
    _selectedAddressIndexBox = Hive.box<int>('selectedAddressIndexBox');
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

  // Modify _onItemTapped method
  void _onItemTapped(int index) {
    if (index == 0) {
      // Home tab
      Navigator.pop(context);
    } else if (index == 2) {
      // Menu tab
      _showSlidingSidebar(); // Add this line
    }
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
                    // Address Section - Moved inside SingleChildScrollView
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
                                      selectedAddress?.recipientName ?? 'Nama Penerima', // Use selected address or default
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Added fontSize
                                    ),
                                    Text(selectedAddress?.fullAddress ?? 'Alamat penerima'), // Use selected address or default
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async { // Make the onTap async
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddressListScreen(),
                                    ),
                                  );
                                  // No need to setState here, ValueListenableBuilder handles it
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
                          //pesanan title
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
                                children: widget.viewModel.cartItems.map((
                                  cartItem,
                                ) {
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.asset(
                                              cartItem.menuItem.image,
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                    width:
                                                        24, // Ukuran dikecilkan
                                                    height:
                                                        24, // Ukuran dikecilkan
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1,
                                                      ), // Tambah border hitam
                                                    ),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        widget.viewModel
                                                            .updateCartItemQuantity(
                                                              cartItem
                                                                  .menuItem
                                                                  .id,
                                                              cartItem.quantity -
                                                                  1,
                                                            );
                                                      },
                                                      icon: Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size:
                                                            14, // Ukuran icon dikecilkan
                                                      ),
                                                    ),
                                                  ),

                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    child: Text(
                                                      cartItem.quantity
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),

                                                  // Increase button
                                                  Container(
                                                    width:
                                                        24, // Ukuran dikecilkan
                                                    height:
                                                        24, // Ukuran dikecilkan
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1,
                                                      ), // Tambah border hitam
                                                    ),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        widget.viewModel
                                                            .updateCartItemQuantity(
                                                              cartItem
                                                                  .menuItem
                                                                  .id,
                                                              cartItem.quantity +
                                                                  1,
                                                            );
                                                      },
                                                      icon: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size:
                                                            14, // Ukuran icon dikecilkan
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(
                                                    width: 8,
                                                  ), // Jarak antara tombol plus dan delete
                                                  // Delete button dipindah ke samping tombol plus
                                                  Container(
                                                    width:
                                                        24, // Ukuran disesuaikan dengan tombol lain
                                                    height:
                                                        24, // Ukuran disesuaikan dengan tombol lain
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        widget.viewModel
                                                            .removeFromCart(
                                                              cartItem
                                                                  .menuItem
                                                                  .id,
                                                            );
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size:
                                                            18, // Ukuran icon dikecilkan
                                                      ),
                                                    ),
                                                  ),

                                                  Spacer(),

                                                  // Price
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Rp ${cartItem.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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

                          // Total and Notes
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
                              Container(
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
                        //payment method content
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //metode pembayaran
                              Text(
                                'Metode Pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              //payment option button
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, // Warna latar
                                  foregroundColor: Colors.black, // Warna teks
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
                                  'gopay',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Payment Details(subtotal, ongkir, admin fee, total)
                          AnimatedBuilder(
                            animation: widget.viewModel,
                            builder: (context, child) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    //subtotal
                                    children: [
                                      Text('Subtotal'),
                                      Text(
                                        'Rp ${widget.viewModel.subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),

                                  //biaya ongkir
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ongkir'),
                                      Text(
                                        'Rp ${widget.viewModel.shippingCost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),

                                  //biaya admin
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Biaya Admin'),
                                      Text(
                                        'Rp ${widget.viewModel.adminFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                      ),
                                    ],
                                  ),
                                  Divider(height: 24),

                                  //total price
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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

                          // Promo Code
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
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.viewModel.cartItems.isNotEmpty
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Konfirmasi Pesanan'),
                              content: Text('Pesanan Anda telah dikonfirmasi!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.viewModel.clearCart();
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
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
                ),
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
