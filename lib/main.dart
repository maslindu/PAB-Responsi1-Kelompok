import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      home: MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Model untuk Menu Item
class MenuItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  final String description;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
  });
}

// Model untuk Cart Item
class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({
    required this.menuItem,
    required this.quantity,
  });

  double get totalPrice => menuItem.price * quantity;
}

// ViewModel untuk mengelola state
class MenuViewModel extends ChangeNotifier {
  List<MenuItem> _menuItems = [
    MenuItem(
      id: '1',
      name: 'Dish 1',
      category: 'Kategori 1',
      price: 15000,
      image: 'https://via.placeholder.com/150',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '2',
      name: 'Dish 2',
      category: 'Kategori 2',
      price: 20000,
      image: 'https://via.placeholder.com/150',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '3',
      name: 'Nama Menu',
      category: 'Kategori 1',
      price: 10000,
      image: 'https://via.placeholder.com/150',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '4',
      name: 'Nama Menu',
      category: 'Kategori 2',
      price: 10000,
      image: 'https://via.placeholder.com/150',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '5',
      name: 'Nama Menu',
      category: 'Kategori 3',
      price: 10000,
      image: 'https://via.placeholder.com/150',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '6',
      name: 'Nama Menu',
      category: 'Kategori 1',
      price: 10000,
      image: 'https://via.placeholder.com/150',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
  ];

  List<CartItem> _cartItems = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String _orderNotes = '';

  // Getters
  List<MenuItem> get menuItems {
    List<MenuItem> filteredItems = _menuItems;
    
    if (_selectedCategory != 'Semua') {
      filteredItems = filteredItems.where((item) => item.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) => 
        item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    return filteredItems;
  }

  List<CartItem> get cartItems => _cartItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get orderNotes => _orderNotes;
  
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  double get shippingCost => 0; // Free shipping
  double get taxes => subtotal * 0.1; // 10% tax
  double get total => subtotal + shippingCost + taxes;

  List<String> get categories => ['Semua', 'Kategori 1', 'Kategori 2', 'Kategori 3'];

  // Methods
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setOrderNotes(String notes) {
    _orderNotes = notes;
    notifyListeners();
  }

  void addToCart(MenuItem menuItem, int quantity) {
    final existingIndex = _cartItems.indexWhere((item) => item.menuItem.id == menuItem.id);
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(menuItem: menuItem, quantity: quantity));
    }
    
    notifyListeners();
  }

  void updateCartItemQuantity(String menuItemId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(String menuItemId) {
    _cartItems.removeWhere((item) => item.menuItem.id == menuItemId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _orderNotes = '';
    notifyListeners();
  }
}

// Main Screen
class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuViewModel _viewModel = MenuViewModel();
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _viewModel.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) { // Cart tab
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(viewModel: _viewModel),
        ),
      );
      // Setelah kembali dari Checkout, pindah ke Home
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  void _showMenuDetail(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuDetailPopup(
        menuItem: item,
        viewModel: _viewModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      Stack(
                        children: [
                          Icon(Icons.notifications, color: Colors.white, size: 28),
                          AnimatedBuilder(
                            animation: _viewModel,
                            builder: (context, child) {
                              if (_viewModel.cartItemCount > 0) {
                                return Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${_viewModel.cartItemCount}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Good Afternoon, User!',
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
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Menu',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Address Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[300],
                borderRadius: BorderRadius.circular(16),
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
                          'Nama Penerima',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Jl. surakarta no.xx'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Ganti Alamat'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Recommendation Menu Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recommendation Menu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Category Filter
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _viewModel.categories.length,
                itemBuilder: (context, index) {
                  final category = _viewModel.categories[index];
                  final isSelected = _viewModel.selectedCategory == category;
                  
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
                      backgroundColor: Colors.white,
                      selectedColor: Colors.red[100],
                      checkmarkColor: Colors.red,
                      side: BorderSide(
                        color: isSelected ? Colors.red : Colors.grey[300]!,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // Menu Grid (Lazy Loading)
            Expanded(
              child: AnimatedBuilder(
                animation: _viewModel,
                builder: (context, child) {
                  return GridView.builder(
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                AnimatedBuilder(
                  animation: _viewModel,
                  builder: (context, child) {
                    if (_viewModel.cartItemCount > 0) {
                      return Positioned(
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
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Menu Card Component
class MenuCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback onTap;

  const MenuCard({
    Key? key,
    required this.menuItem,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    menuItem.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      menuItem.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Rp ${menuItem.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Menu Detail Popup
class MenuDetailPopup extends StatefulWidget {
  final MenuItem menuItem;
  final MenuViewModel viewModel;

  const MenuDetailPopup({
    Key? key,
    required this.menuItem,
    required this.viewModel,
  }) : super(key: key);

  @override
  _MenuDetailPopupState createState() => _MenuDetailPopupState();
}

class _MenuDetailPopupState extends State<MenuDetailPopup> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Image
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.menuItem.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image, color: Colors.grey[600], size: 40),
                          );
                        },
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.menuItem.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Quantity and Add to Cart
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
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: quantity > 1 ? () {
                                setState(() {
                                  quantity--;
                                });
                              } : null,
                              icon: Icon(Icons.remove, color: Colors.white),
                              iconSize: 20,
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
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              icon: Icon(Icons.add, color: Colors.white),
                              iconSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.viewModel.addToCart(widget.menuItem, quantity);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.menuItem.name} ditambahkan ke pesanan'),
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
          ),
          
          // Bottom Navigation (same as main screen)
          BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: 'Menu',
              ),
            ],
            currentIndex: 0,
            selectedItemColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

// Checkout Screen
class CheckoutScreen extends StatefulWidget {
  final MenuViewModel viewModel;

  const CheckoutScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  int _selectedIndex = 1; // Cart tab selected

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.viewModel.orderNotes;
    _notesController.addListener(() {
      widget.viewModel.setOrderNotes(_notesController.text);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 0) { // Home tab
      Navigator.pop(context);
    }
  }

  void _confirmOrder() {
    if (widget.viewModel.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keranjang kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Pesanan'),
        content: Text('Apakah Anda yakin ingin melanjutkan pesanan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.viewModel.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pesanan berhasil dikonfirmasi!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Konfirmasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                // Address Section
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[300],
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
                              'Nama Penerima',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Jl. surakarta no.xx'),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: Text('Ganti Alamat'),
                      ),
                    ],
                  ),
                ),

                // Order Items Section
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pesanan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Cart Items List
                        Expanded(
                          child: widget.viewModel.cartItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'Keranjang kosong',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: widget.viewModel.cartItems.length,
                                  separatorBuilder: (context, index) => Divider(),
                                  itemBuilder: (context, index) {
                                    final cartItem = widget.viewModel.cartItems[index];
                                    return CartItemWidget(
                                      cartItem: cartItem,
                                      onQuantityChanged: (newQuantity) {
                                        widget.viewModel.updateCartItemQuantity(
                                          cartItem.menuItem.id,
                                          newQuantity,
                                        );
                                      },
                                      onRemove: () {
                                        widget.viewModel.removeFromCart(cartItem.menuItem.id);
                                      },
                                    );
                                  },
                                ),
                        ),
                        
                        if (widget.viewModel.cartItems.isNotEmpty) ...[
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total : Rp ${widget.viewModel.subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Show notes dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Catatan Pesanan'),
                                      content: TextField(
                                        controller: _notesController,
                                        decoration: InputDecoration(
                                          hintText: 'Tambahkan catatan...',
                                          border: OutlineInputBorder(),
                                        ),
                                        maxLines: 3,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Tutup'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.black),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.note_add),
                                    SizedBox(width: 4),
                                    Text('Catatan'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Notes Section
                Container(
                  margin: EdgeInsets.all(16),
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      widget.viewModel.orderNotes.isEmpty 
                          ? 'Tidak ada catatan'
                          : widget.viewModel.orderNotes,
                      style: TextStyle(
                        color: widget.viewModel.orderNotes.isEmpty 
                            ? Colors.grey[600] 
                            : Colors.black,
                      ),
                    ),
                  ),
                ),

                // Price Breakdown
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal (${widget.viewModel.cartItemCount})'),
                          Text('Rp ${widget.viewModel.subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shipping total'),
                          Text('Free'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Taxes'),
                          Text('Rp ${widget.viewModel.taxes.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rp ${widget.viewModel.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Confirm Order Button
                Container(
                  margin: EdgeInsets.all(16),
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
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
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Cart Item Widget
class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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
              child: Image.network(
                cartItem.menuItem.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey[600]),
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
                    fontSize: 14,
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
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        onTap: () {
                          if (cartItem.quantity > 1) {
                            onQuantityChanged(cartItem.quantity - 1);
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          child: Icon(Icons.remove, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        cartItem.quantity.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        onTap: () {
                          onQuantityChanged(cartItem.quantity + 1);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          child: Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Delete Button
                    InkWell(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Price
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
  }
}