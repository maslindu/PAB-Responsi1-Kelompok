import 'package:flutter/material.dart';
import '../viewmodels/menu_view_model.dart';
import '../widgets/menu_card.dart';
import '../widgets/menu_detail_popup.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/address.dart';
import 'checkout_screen.dart';
import 'sliding_sidebar.dart';
import 'address_list_screen.dart';
import 'edit_profile_screen.dart'; // Import the edit profile screen
import '../models/user.dart'; // Import User model
import 'dart:io'; // Import dart:io for File
import '../models/payment.dart';
import '../models/transaction.dart'; // Import Transaction model
import 'payment_screen.dart';
import 'order_status_screen.dart'; // Import the new OrderStatusScreen

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuViewModel _viewModel = MenuViewModel();
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  late Box<User> _userBox;
  late Box<Address> _addressBox;
  late Box<int> _selectedAddressIndexBox;
  late Box<Transaction> _transactionBox;
  late Box<String> _lastTransactionIdBox; // Declare last transaction ID box

  @override
  void initState() {
    super.initState();
    // Fix the search functionality - add listener for real-time search
    _searchController.addListener(() {
      _viewModel.setSearchQuery(_searchController.text);
    });
    _userBox = Hive.box<User>('userBox');
    _addressBox = Hive.box<Address>('addresses');
    _selectedAddressIndexBox = Hive.box<int>('selectedAddressIndexBox');
    _transactionBox = Hive.box<Transaction>('transactionBox');
    _lastTransactionIdBox = Hive.box<String>('lastTransactionIdBox'); // Initialize last transaction ID box
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose(); // Make sure to dispose the view model
    super.dispose();
  }

  void _showNotificationScreen() {
    final lastTransactionId = _lastTransactionIdBox.get('lastTransactionId');
    if (lastTransactionId != null) {
      final transaction = _transactionBox.get(lastTransactionId);
      final paymentBox = Hive.box<Payment>('paymentBox');
      final payment = paymentBox.get(lastTransactionId); // Assuming payment ID is same as transaction ID

      if (transaction != null && payment != null) {
        // Check if payment is completed (paid or processing order)
        if (payment.status == 'completed' || transaction.status != 'pending') {
          // Navigate to OrderStatusScreen for completed payments
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderStatusScreen(
                payment: payment,
                transaction: transaction,
              ),
            ),
          );
        } else if (transaction.status != 'completed' && transaction.status != 'cancelled') {
          // Navigate to PaymentScreen for pending payments
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                payment: payment,
                transaction: transaction,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak ada notifikasi pembayaran aktif.'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data transaksi tidak ditemukan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada notifikasi pembayaran.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Cart tab
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(viewModel: _viewModel),
        ),
      ).then((_) {
        // When returning from CheckoutScreen, reset to home tab
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  void _showMenuDetail(item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuDetailPopup(
        menuItem: item,
        onAddToCart: (quantity) {
          _viewModel.addToCart(item, quantity);
        },
      ),
    );
  }

  String _getGreeting(User? user) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    // Use actual username if available
    return '$greeting, ${user?.username ?? 'User'}!';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          // Add this wrapper
          child: ValueListenableBuilder<Box<User>>(
            valueListenable: _userBox.listenable(),
            builder: (context, box, _) {
              final currentUser = box.isNotEmpty ? box.getAt(0) : null;
              return Column(
                children: [
                  // Header Section
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(254, 74, 73, 1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfileScreen(),
                                  ),
                                );
                                // No need to setState here, ValueListenableBuilder handles it
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                backgroundImage:
                                    (currentUser?.profilePicturePath != null &&
                                        currentUser!.profilePicturePath
                                            .startsWith('assets/'))
                                    ? AssetImage(currentUser.profilePicturePath)
                                    : (currentUser?.profilePicturePath !=
                                              null &&
                                          currentUser
                                                  ?.profilePicturePath
                                                  .isNotEmpty ==
                                              true)
                                    ? FileImage(
                                            File(
                                              currentUser!.profilePicturePath,
                                            ),
                                          )
                                          as ImageProvider<Object>
                                    : AssetImage(
                                        'assets/images/default_profile.png',
                                      ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showNotificationScreen, // Changed to new method
                              child: Stack(
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 28,
                                  ),

                                  // Payment status notification dot
                                  ValueListenableBuilder<Box<String>>(
                                    valueListenable: _lastTransactionIdBox.listenable(),
                                    builder: (context, box, _) {
                                      final lastTransactionId = box.get('lastTransactionId');
                                      final transaction = lastTransactionId != null ? _transactionBox.get(lastTransactionId) : null;
                                      final paymentBox = Hive.box<Payment>('paymentBox');
                                      final payment = lastTransactionId != null ? paymentBox.get(lastTransactionId) : null;
                                      
                                      bool hasActiveNotification = false;
                                      Color notificationColor = Colors.yellow;
                                      
                                      if (transaction != null && payment != null) {
                                        // Show notification for pending payments
                                        if (payment.status == 'pending') {
                                          hasActiveNotification = true;
                                          notificationColor = Colors.red; // Red for pending payment
                                        }
                                        // Show notification for active orders (paid, preparing, delivering)
                                        else if (transaction.status == 'paid' || 
                                                transaction.status == 'preparing' || 
                                                transaction.status == 'delivering') {
                                          hasActiveNotification = true;
                                          notificationColor = Colors.green; // Green for active order
                                        }
                                      }

                                      if (!hasActiveNotification) {
                                        return SizedBox.shrink();
                                      }

                                      return Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: notificationColor,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            '!', // Exclamation mark for notification
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _getGreeting(currentUser),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Menu',
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              suffixIcon: AnimatedBuilder(
                                animation: _viewModel,
                                builder: (context, child) {
                                  return _viewModel.isSearchActive
                                      ? IconButton(
                                          icon: Icon(Icons.clear, color: Colors.grey),
                                          onPressed: () {
                                            _searchController.clear();
                                            _viewModel.setSearchQuery('');
                                          },
                                        )
                                      : SizedBox.shrink();
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            // Add this to trigger search on every text change
                            onChanged: (value) {
                              // This will automatically trigger the search
                              // because we already have the listener set up in initState
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Address Section
                  ValueListenableBuilder<Box<int>>(
                    valueListenable: _selectedAddressIndexBox.listenable(),
                    builder: (context, box, _) {
                      final selectedIndex = box.get('selected');
                      final selectedAddress =
                          selectedIndex != null && _addressBox.isNotEmpty
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
                                    selectedAddress?.recipientName ??
                                        'Nama Penerima', // Use selected address or default
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ), // Added fontSize
                                  ),
                                  Text(
                                    selectedAddress?.fullAddress ??
                                        'Alamat penerima',
                                  ), // Use selected address or default
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

                  SizedBox(height: 20),

                  // Conditional Recommendation Menu Section
                  AnimatedBuilder(
                    animation: _viewModel,
                    builder: (context, child) {
                      // Only show recommendations when not searching
                      if (!_viewModel.isSearchActive && _viewModel.recommendedItems.isNotEmpty) {
                        return Column(
                          children: [
                            // Recommendation Menu Title with Refresh Button
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recommendation Menu',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Horizontal Recommendation Menu
                            Container(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _viewModel.recommendedItems.length,
                                itemBuilder: (context, index) {
                                  final item = _viewModel.recommendedItems[index];
                                  return Container(
                                    width: 160,
                                    margin: EdgeInsets.only(right: 12),
                                    child: MenuCard(
                                      menuItem: item,
                                      onTap: () => _showMenuDetail(item),
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: 20),
                          ],
                        );
                      } else if (_viewModel.isSearchActive) {
                        // Show search results count when searching
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Hasil pencarian untuk "${_viewModel.searchQuery}" (${_viewModel.menuItems.length} item)',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),

                  // Category Filter
                  Container(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _viewModel.categories.length,
                      itemBuilder: (context, index) {
                        final category = _viewModel.categories[index];
                        final isSelected =
                            _viewModel.selectedCategory == category;

                        Color borderColor;
                        Color backgroundColor;

                        switch (index % 3) {
                          case 0:
                            borderColor = Colors.red;
                            backgroundColor = isSelected
                                ? Colors.red[100]!
                                : Colors.white;
                            break;
                          case 1:
                            borderColor = Colors.blue;
                            backgroundColor = isSelected
                                ? Colors.blue[100]!
                                : Colors.white;
                            break;
                          case 2:
                            borderColor = Colors.orange;
                            backgroundColor = isSelected
                                ? Colors.orange[100]!
                                : Colors.white;
                            break;
                          case 3:
                            borderColor = Colors.blue;
                            backgroundColor = isSelected
                                ? Colors.blue[100]!
                                : Colors.white;
                            break;
                          default:
                            borderColor = Colors.grey;
                            backgroundColor = Colors.white;
                        }

                        return Container(
                          margin: EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _viewModel.setSelectedCategory(category);
                              });
                            },
                            backgroundColor: backgroundColor,
                            selectedColor: backgroundColor,
                            checkmarkColor: borderColor,
                            side: BorderSide(color: borderColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Menu Grid
                  AnimatedBuilder(
                    animation: _viewModel,
                    builder: (context, child) {
                      if (_viewModel.menuItems.isEmpty && _viewModel.isSearchActive) {
                        // Show no results found message
                        return Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada menu yang ditemukan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Coba kata kunci lain',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true, // Add this
                        physics: NeverScrollableScrollPhysics(), // Add this
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _viewModel.menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _viewModel.menuItems[index];
                          return MenuCard(
                            menuItem: item,
                            onTap: () => _showMenuDetail(item),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: 80,
                  ), // Add extra space at the bottom to prevent overflow
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          return BottomNavigationBar(
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(Icons.shopping_cart),
                    if (_viewModel.cartItemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${_viewModel.cartItemCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.red,
            onTap: (index) {
              if (index == 2) {
                _showSlidingSidebar();
              } else {
                _onItemTapped(index);
              }
            },
          );
        },
      ),
    );
  }
}