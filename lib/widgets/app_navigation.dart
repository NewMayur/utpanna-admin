import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum NavigationItem {
  dashboard,
  deals,
  products,
  crops,
  users,
}

extension NavigationItemExtension on NavigationItem {
  String get title {
    switch (this) {
      case NavigationItem.dashboard:
        return 'Dashboard';
      case NavigationItem.deals:
        return 'Group Deals';
      case NavigationItem.products:
        return 'Products & Alternatives';
      case NavigationItem.crops:
        return 'Crops Combo';
      case NavigationItem.users:
        return 'Users';
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationItem.dashboard:
        return Icons.dashboard;
      case NavigationItem.deals:
        return Icons.group_work;
      case NavigationItem.products:
        return Icons.inventory;
      case NavigationItem.crops:
        return Icons.grass;
      case NavigationItem.users:
        return Icons.people;
    }
  }

  String get route {
    switch (this) {
      case NavigationItem.dashboard:
        return '/dashboard';
      case NavigationItem.deals:
        return '/deals';
      case NavigationItem.products:
        return '/products';
      case NavigationItem.crops:
        return '/crops';
      case NavigationItem.users:
        return '/users';
    }
  }
}

class AppNavigationDrawer extends StatefulWidget {
  final NavigationItem selectedItem;
  final Function(NavigationItem) onItemSelected;

  const AppNavigationDrawer({
    Key? key,
    required this.selectedItem,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.navBackground,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: AppSpacing.xxl + AppSpacing.md, // Account for status bar
              bottom: AppSpacing.xl,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSpacing.lg),
                bottomRight: Radius.circular(AppSpacing.lg),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppBorderRadius.mdRadius,
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Utpanna Admin',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Farm Management System',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: NavigationItem.values.map((item) {
                final isSelected = widget.selectedItem == item;
                return _buildNavigationItem(item, isSelected);
              }).toList(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Version 1.0.0',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textDisabled,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.navItemActive : Colors.transparent,
        borderRadius: AppBorderRadius.mdRadius,
      ),
      child: ListTile(
        onTap: () {
          widget.onItemSelected(item);
          // Close drawer on mobile
          if (MediaQuery.of(context).size.width < 1024) {
            Navigator.of(context).pop();
          }
        },
        leading: Icon(
          item.icon,
          color:
              isSelected ? AppColors.navItemTextActive : AppColors.navItemText,
          size: 20,
        ),
        title: Text(
          item.title,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected
                ? AppColors.navItemTextActive
                : AppColors.navItemText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdRadius,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        dense: true,
        selected: isSelected,
        selectedTileColor: AppColors.navItemActive,
        hoverColor: AppColors.primaryLight.withOpacity(0.1),
      ),
    );
  }
}

// Desktop Sidebar Navigation
class AppNavigationRail extends StatefulWidget {
  final NavigationItem selectedItem;
  final Function(NavigationItem) onItemSelected;
  final double? width;

  const AppNavigationRail({
    Key? key,
    required this.selectedItem,
    required this.onItemSelected,
    this.width = 280,
  }) : super(key: key);

  @override
  State<AppNavigationRail> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends State<AppNavigationRail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      color: AppColors.navBackground,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.xl,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(AppSpacing.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppBorderRadius.mdRadius,
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Utpanna Admin',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Farm System',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: NavigationItem.values.map((item) {
                final isSelected = widget.selectedItem == item;
                return _buildNavigationItem(item, isSelected);
              }).toList(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'v1.0.0',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textDisabled,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.navItemActive : Colors.transparent,
        borderRadius: AppBorderRadius.mdRadius,
      ),
      child: ListTile(
        onTap: () => widget.onItemSelected(item),
        leading: Icon(
          item.icon,
          color:
              isSelected ? AppColors.navItemTextActive : AppColors.navItemText,
          size: 24,
        ),
        title: Text(
          item.title,
          style: AppTypography.bodyLarge.copyWith(
            color: isSelected
                ? AppColors.navItemTextActive
                : AppColors.navItemText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdRadius,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        selected: isSelected,
        selectedTileColor: AppColors.navItemActive,
        hoverColor: AppColors.primaryLight.withOpacity(0.1),
      ),
    );
  }
}

// Responsive Layout Helper
class ResponsiveLayout extends StatelessWidget {
  final NavigationItem selectedItem;
  final Function(NavigationItem) onItemSelected;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? appBarActions;
  final String title;

  const ResponsiveLayout({
    Key? key,
    required this.selectedItem,
    required this.onItemSelected,
    required this.body,
    required this.title,
    this.floatingActionButton,
    this.appBarActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          // Desktop Layout
          return Scaffold(
            body: Row(
              children: [
                AppNavigationRail(
                  selectedItem: selectedItem,
                  onItemSelected: onItemSelected,
                ),
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(title),
                      elevation: 1,
                      actions: appBarActions,
                    ),
                    body: body,
                    floatingActionButton: floatingActionButton,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile Layout
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              elevation: 1,
              actions: appBarActions,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
            drawer: AppNavigationDrawer(
              selectedItem: selectedItem,
              onItemSelected: onItemSelected,
            ),
            body: body,
            floatingActionButton: floatingActionButton,
          );
        }
      },
    );
  }
}
