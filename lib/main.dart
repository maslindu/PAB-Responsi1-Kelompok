import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/menu_screen.dart';
import 'models/address.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AddressAdapter());
  await Hive.openBox<Address>('addresses');
  
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
      home: MenuScreen(),
    );
  }
}
