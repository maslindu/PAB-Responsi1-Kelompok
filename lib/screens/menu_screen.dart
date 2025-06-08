import 'package:flutter/material.dart';
import '../viewmodels/menu_view_model.dart';
import '../widgets/menu_card.dart';
import '../widgets/menu_detail_popup.dart';
import 'checkout_screen.dart';
import 'sliding_sidebar.dart';

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
          child: Column(
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
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        Stack(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 28,
                            ),
                            if (_viewModel.cartItemCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
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
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Menu',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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
                            'Nama Penerima',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Jl. surakarta no.xx'),
                        ],
                      ),
                    ),
                    Container(
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Horizontal Recommendation Menu
              Container(
                height: 200,
                child: AnimatedBuilder(
                  animation: _viewModel,
                  builder: (context, child) {
                    return ListView.builder(
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
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

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
              GridView.builder(
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
              ),
            ],
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
