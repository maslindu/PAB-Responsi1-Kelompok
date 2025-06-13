import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';
import '../models/address.dart'; // Import Address model
import '../models/user.dart'; // Import User model

class MenuViewModel extends ChangeNotifier {
  late Box<CartItem> _cartBox;
  late Box<Address> _addressBox;
  late Box<int> _selectedAddressIndexBox;

  MenuViewModel() {
    _cartBox = Hive.box<CartItem>('cartBox');
    _addressBox = Hive.box<Address>('addresses');
    _selectedAddressIndexBox = Hive.box<int>('selectedAddressIndexBox');
    _cartItems = _cartBox.values.toList();

    // Initialize default user if userBox is empty
    final userBox = Hive.box<User>('userBox');
    if (userBox.isEmpty) {
      final defaultUser = User(
        fullName: 'Nama User',
        username: 'user_name',
        email: 'email@example.com',
        phoneNumber: '081234567890',
      );
      userBox.add(defaultUser);
    }

    // Listen for changes in the selected address index
    _selectedAddressIndexBox.listenable().addListener(() {
      notifyListeners(); // Notify listeners when selected address changes
    });
  }

  List<MenuItem> _menuItems = [
    MenuItem(
      id: '1',
      name: 'Nasi Goreng',
      category: 'Makanan Berat',
      price: 15000,
      image: 'assets/images/Fried Rice Aesthetic.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiuf agegrgffkjlhagbahbg ahbfuwe wwhkhhfbjkasnfdclnasiufbb  hiwofhjwkugfbyuiabvybdscvhksabvf whf piouqfhiuf smod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '2',
      name: 'Nasi Uduk',
      category: 'Makanan Berat',
      price: 13000,
      image: 'assets/images/Nasi Uduk.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '3',
      name: 'Roti Bakar',
      category: 'Makanan Ringan',
      price: 10000,
      image: 'assets/images/Roti bakar.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '4',
      name: 'Kentang Goreng',
      category: 'Makanan Ringan',
      price: 10000,
      image: 'assets/images/KENTANG GORENG.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '5',
      name: 'Soda Gembira',
      category: 'Minuman',
      price: 10000,
      image: 'assets/images/Soda gembira.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '6',
      name: 'Milk Tea',
      category: 'Minuman',
      price: 10000,
      image: 'assets/images/How To Make Milk Tea.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '7',
      name: 'Es Krim',
      category: 'Dessert',
      price: 12000,
      image: 'assets/images/Es Krim.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '8',
      name: 'Brownies',
      category: 'Dessert',
      price: 12000,
      image: 'assets/images/Brownies.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '9',
      name: 'Es Teh',
      category: 'Minuman',
      price: 4000,
      image: 'assets/images/Es Teh.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '10',
      name: 'Ayam Bakar',
      category: 'Makanan Berat',
      price: 18000,
      image: 'assets/images/Ayam Bakar.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    MenuItem(
      id: '11',
      name: 'Sate Ayam',
      category: 'Makanan Berat',
      price: 20000,
      image: 'assets/images/Sate Ayam.png',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
  ];

  List<CartItem> _cartItems = []; // This will be initialized from Hive
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String _notes = ''; // New field for notes

  // Getters
  List<MenuItem> get menuItems {
    List<MenuItem> filteredItems = _menuItems;

    if (_selectedCategory != 'Semua') {
      filteredItems = filteredItems
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filteredItems;
  }

  List<MenuItem> get recommendedItems => _menuItems.take(4).toList();
  List<CartItem> get cartItems => List.unmodifiable(_cartItems); // Return unmodifiable list
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get notes => _notes; // Getter for notes

  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  
  double get shippingCost {
    return _calculateShippingCost();
  }

  double get adminFee => 1000;
  double get total => subtotal + shippingCost + adminFee;

  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  List<String> get categories => [
    'Semua',
    'Makanan Berat',
    'Makanan Ringan',
    'Dessert',
    'Minuman',
  ];

  // Methods
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  void addToCart(MenuItem menuItem, int quantity) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.menuItem.id == menuItem.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
      _cartBox.putAt(existingIndex, _cartItems[existingIndex]); // Update in Hive
    } else {
      final newCartItem = CartItem(menuItem: menuItem, quantity: quantity);
      _cartItems.add(newCartItem);
      _cartBox.add(newCartItem); // Add to Hive
    }
    notifyListeners();
  }

  void updateCartItemQuantity(String itemId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.menuItem.id == itemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
        _cartBox.deleteAt(index); // Delete from Hive
      } else {
        _cartItems[index].quantity = newQuantity;
        _cartBox.putAt(index, _cartItems[index]); // Update in Hive
      }
      notifyListeners();
    }
  }

  void removeFromCart(String itemId) {
    final index = _cartItems.indexWhere((item) => item.menuItem.id == itemId);
    if (index >= 0) {
      _cartItems.removeAt(index);
      _cartBox.deleteAt(index); // Delete from Hive
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _cartBox.clear(); // Clear Hive box
    notifyListeners();
  }

  double _calculateShippingCost() {
    final selectedIndex = _selectedAddressIndexBox.get('selected');
    if (selectedIndex != null && _addressBox.isNotEmpty) {
      final selectedAddress = _addressBox.getAt(selectedIndex);
      if (selectedAddress != null && selectedAddress.fullAddress.isNotEmpty) {
        final firstChar = selectedAddress.fullAddress.toUpperCase().codeUnitAt(0);
        if (firstChar >= 'A'.codeUnitAt(0) && firstChar <= 'Z'.codeUnitAt(0)) {
          // 'A' = 10000, 'B' = 11000, 'C' = 12000, etc.
          return 10000 + (firstChar - 'A'.codeUnitAt(0)) * 1000;
        }
      }
    }
    return 0.0; // Default shipping cost if no address or invalid address
  }
}
