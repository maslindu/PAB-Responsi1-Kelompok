import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/menu_item.dart';
import '../widgets/menu_card.dart'; // Assuming MenuCard can be reused
import '../widgets/menu_detail_popup.dart'; // Import MenuDetailPopup

class FavoriteMenuScreen extends StatelessWidget {
  const FavoriteMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Favorit'),
        backgroundColor: Colors.red,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<MenuItem>('favoriteMenus').listenable(),
        builder: (context, Box<MenuItem> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Belum ada menu favorit.'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final MenuItem menuItem = box.getAt(index)!;
              return MenuCard(
                menuItem: menuItem,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => MenuDetailPopup(
                      menuItem: menuItem,
                      onAddToCart: (quantity) {
                        // This screen doesn't handle adding to cart directly,
                        // but MenuDetailPopup requires it. Can be a no-op or show a message.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${menuItem.name} added to cart from favorites!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
