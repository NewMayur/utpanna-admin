import 'package:flutter/material.dart';
import '../widgets/app_navigation.dart';
import '../services/farming_data_service.dart';
import 'dashboard_screen.dart';
import 'products_screen.dart';
import 'crops_combo_screen.dart';
import 'group_deals_screen.dart';
import 'users_screen.dart';

class MainAdminPanel extends StatefulWidget {
  const MainAdminPanel({Key? key}) : super(key: key);

  @override
  State<MainAdminPanel> createState() => _MainAdminPanelState();
}

class _MainAdminPanelState extends State<MainAdminPanel> {
  NavigationItem _selectedItem = NavigationItem.dashboard;

  void _onNavigationItemSelected(NavigationItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedItem) {
      case NavigationItem.dashboard:
        return DashboardScreen(onNavigateTo: _onNavigationItemSelected);
      case NavigationItem.deals:
        return const GroupDealsScreen();
      case NavigationItem.products:
        return const ProductsScreen();
      case NavigationItem.crops:
        return const CropsComboScreen();
      case NavigationItem.users:
        return const UsersScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      selectedItem: _selectedItem,
      onItemSelected: _onNavigationItemSelected,
      title: _selectedItem.title,
      body: _getCurrentScreen(),
    );
  }
}
