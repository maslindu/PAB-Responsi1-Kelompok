import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/menu_screen.dart';
import 'screens/loading_screen.dart'; // Import the loading screen
import 'models/address.dart';
import 'models/menu_item.dart'; // Import MenuItem
import 'models/user.dart'; // Import User model
import 'models/cart_item.dart'; // Import CartItem model

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Hive.initFlutter();
  Hive.registerAdapter(AddressAdapter());
  Hive.registerAdapter(MenuItemAdapter()); // Register MenuItemAdapter
  Hive.registerAdapter(UserAdapter()); // Register UserAdapter
  Hive.registerAdapter(CartItemAdapter()); // Register CartItemAdapter
  await Hive.openBox<Address>('addresses');
  await Hive.openBox<MenuItem>('favoriteMenus'); // Open a new box for favorite menus
  await Hive.openBox<User>('userBox'); // Open a new box for user data
  await Hive.openBox<int>('selectedAddressIndexBox'); // Open a new box for selected address index
  await Hive.openBox<CartItem>('cartBox'); // Open a new box for cart items
  
  // Set system UI overlay style (optional)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: LoadingScreen(
        nextScreen: MenuScreen(), // Navigate to MenuScreen after loading
      ),
    );
  }
}
