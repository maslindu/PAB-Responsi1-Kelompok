import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/menu_screen.dart';
import 'screens/loading_screen.dart'; // Import the loading screen
import 'models/address.dart';
import 'models/menu_item.dart';
import 'models/user.dart';
import 'models/cart_item.dart';
import 'models/payment.dart';
import 'models/transaction.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register all adapters
  Hive.registerAdapter(AddressAdapter());
  Hive.registerAdapter(MenuItemAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(PaymentAdapter());
  Hive.registerAdapter(TransactionAdapter()); // Add this line
  
  // Open all boxes
  await Hive.openBox<Address>('addresses');
  await Hive.openBox<MenuItem>('favoriteMenus');
  await Hive.openBox<User>('userBox');
  await Hive.openBox<int>('selectedAddressIndexBox');
  await Hive.openBox<CartItem>('cartBox');
  await Hive.openBox<Payment>('paymentBox');
  await Hive.openBox<Transaction>('transactionBox');
  await Hive.openBox<String>('lastTransactionIdBox'); // Open last transaction ID box
  
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
