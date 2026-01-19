import 'package:flutter/material.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/features/home/presentation/pages/dashboard_page.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipes_page.dart';
import 'package:gastronomic_os/features/planner/presentation/pages/planner_page.dart';
import 'package:gastronomic_os/features/inventory/presentation/pages/inventory_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // 1. Try to pop the nested navigator of the current tab
        final isFirstRouteInCurrentTab = !await _navigatorKeys[_currentIndex].currentState!.maybePop();

        if (isFirstRouteInCurrentTab) {
          // 2. If at the root of the current tab...
          if (_currentIndex != 0) {
             // If not on Home tab, switch to Home
             setState(() => _currentIndex = 0);
          } else {
             // If on Home tab root, allow app exit (system back) -> but we set canPop: false.
             // To exit, we would need to let it bubble up, but PopScope doesn't easily allow "retry".
             // Standard pattern: if we are here, we might want to close the app.
             // For strict PopScope usage:
             if (context.mounted) Navigator.of(context).pop(); 
          }
        }
      },
      child: Scaffold(
        extendBody: true, // Allows body to go behind the navbar
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildTabNavigator(0, const DashboardPage()),
            _buildTabNavigator(1, const RecipesPage()),
            _buildTabNavigator(2, const PlannerPage()),
            _buildTabNavigator(3, const InventoryPage()),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: SafeArea( // Ensures it respects bottom notch/indicator
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, AppLocalizations.of(context).navHome),
                  _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book_rounded, AppLocalizations.of(context).navCookbook),
                  _buildNavItem(2, Icons.calendar_today_outlined, Icons.calendar_month_rounded, AppLocalizations.of(context).navPlanner),
                  _buildNavItem(3, Icons.kitchen_outlined, Icons.kitchen_rounded, AppLocalizations.of(context).navFridge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex == index) {
          // If tapping the same tab, pop to root of that tab!
          _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
        } else {
          setState(() => _currentIndex = index);
        }
      }, 
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? const Color(0xFFCCFF00) : Colors.white54,
              size: 24,
            ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2)),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: isSelected ? const Color(0xFFCCFF00) : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

