import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class MenuDetailPopup extends StatefulWidget {
  final MenuItem menuItem;
  final Function(int) onAddToCart;

  const MenuDetailPopup({
    Key? key,
    required this.menuItem,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  _MenuDetailPopupState createState() => _MenuDetailPopupState();
}

class _MenuDetailPopupState extends State<MenuDetailPopup> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.7,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  children: [
                    // Menu Image
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.menuItem.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Menu Name
                    Text(
                      widget.menuItem.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    // Category
                    Text(
                      widget.menuItem.category,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),

                    SizedBox(height: 16),

                    // Price
                    Text(
                      'Rp ${widget.menuItem.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Description
                    Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.menuItem.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed Bottom Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Quantity Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jumlah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
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
                                onPressed: quantity > 1
                                    ? () {
                                        setState(() {
                                          quantity--;
                                        });
                                      }
                                    : null,
                                icon: Icon(Icons.remove, color: Colors.white),
                                iconSize: 14,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
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
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                icon: Icon(Icons.add, color: Colors.white),
                                iconSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onAddToCart(quantity);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${widget.menuItem.name} ditambahkan ke pesanan',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Tambahkan Pesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
