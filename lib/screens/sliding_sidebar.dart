import 'package:flutter/material.dart';
import 'dart:ui';
import 'address_list_screen.dart';
import 'favorite_menu_screen.dart';
import 'edit_profile_screen.dart';
import 'transaction_list_screen.dart'; // Add this import
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'dart:io';

class SlidingSidebar extends StatefulWidget {
  const SlidingSidebar({Key? key}) : super(key: key);

  @override
  State<SlidingSidebar> createState() => _SlidingSidebarState();
}

class _SlidingSidebarState extends State<SlidingSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Box<User> _userBox;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _userBox = Hive.box<User>('userBox');
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ValueListenableBuilder<Box<User>>(
                          valueListenable: _userBox.listenable(),
                          builder: (context, box, _) {
                            final currentUser = box.isNotEmpty ? box.getAt(0) : null;
                            return Column(
                              children: [
                                // User Profile Section
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(context); // Close sidebar
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const EditProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
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
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: (currentUser?.profilePicturePath != null &&
                                                  currentUser!.profilePicturePath.startsWith('assets/'))
                                              ? AssetImage(currentUser.profilePicturePath)
                                              : (currentUser?.profilePicturePath != null &&
                                                      currentUser!.profilePicturePath.isNotEmpty)
                                                  ? FileImage(File(currentUser.profilePicturePath)) as ImageProvider<Object>
                                                  : AssetImage('assets/images/default_profile.png'),
                                        ),
                                        const SizedBox(width: 15),
                                        // User Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                currentUser?.fullName ?? 'Nama User',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                currentUser?.email ?? 'email@email.com',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                currentUser?.phoneNumber ?? '081234567890',
                                                style: const TextStyle(
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
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddressListScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildMenuItem(
                                        icon: Image.asset(
                                          'assets/images/icons/ActivityHistory.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                        title: 'Daftar Transaksi',
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const TransactionListScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildMenuItem(
                                        icon: Image.asset(
                                          'assets/images/icons/Food.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                        title: 'Menu Favorit',
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const FavoriteMenuScreen(),
                                            ),
                                          );
                                        },
                                      ),                                      
                                      const SizedBox(height: 16),
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
                            );
                          },
                        ),
                      ),
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