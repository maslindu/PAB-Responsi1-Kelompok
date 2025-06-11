import 'package:flutter/material.dart';
import 'dart:ui';
import 'address_list_screen.dart';
import 'favorite_menu_screen.dart'; // Import the new screen

class SlidingSidebar extends StatefulWidget {
  const SlidingSidebar({Key? key}) : super(key: key);

  @override
  State<SlidingSidebar> createState() => _SlidingSidebarState();
}

class _SlidingSidebarState extends State<SlidingSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Blurred background
            GestureDetector(
              onTap: () {
                _controller.reverse().then((_) {
                  Navigator.pop(context);
                });
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5 * _animation.value,
                  sigmaY: 5 * _animation.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3 * _animation.value),
                ),
              ),
            ),
            // Sliding menu from right
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(
                  MediaQuery.of(context).size.width *
                      0.75 *
                      (1 - _animation.value),
                  0,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.black, width: 1),
                    // Tambahkan shadow untuk efek lebih baik
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  // Tambahkan ClipRRect untuk memastikan konten mengikuti rounded corners
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // User Profile Section
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Profile Avatar
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD3D3D3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // User Info
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nama User',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'email@email.com',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '081234567890',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Menu Items
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildMenuItem(
                                icon: Icon(Icons.location_on_outlined),
                                title: 'Daftar Alamat',
                                onTap: () {
                                  Navigator.pop(context); // Close the sidebar
                                  Navigator.push( // Navigate to AddressListScreen
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => AddressListScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                title: 'Daftar Transaksi',
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              _buildMenuItem(
                                title: 'Menu Favorit',
                                onTap: () {
                                  Navigator.pop(context); // Close the sidebar
                                  Navigator.push( // Navigate to FavoriteMenuScreen
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FavoriteMenuScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                title: 'Promo yang Dimiliki',
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(height: 16), // Spacer before logout
                              Container(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'LOGOUT',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem({
    Widget? icon,
    required String title,
    Color textColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: ListTile(
        leading: icon,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.normal,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 8.0,
        ),
      ),
    );
  }
}
