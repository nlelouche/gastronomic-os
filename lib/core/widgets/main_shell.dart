import 'package:flutter/material.dart';
import 'dart:ui' as ui;
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

  final List<Widget> _pages = [
    const DashboardPage(),
    const RecipesPage(),
    const PlannerPage(), // We might need to handle BLoC provision here or inside the page
    const InventoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        extendBody: true, // Important for floating nav
        body: Stack(
          children: [
            // Content
            IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            
            // Floating Glass Nav Bar
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8), // Deep glass
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
                        _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                        _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book_rounded, 'Cookbook'),
                        _buildNavItem(2, Icons.calendar_today_outlined, Icons.calendar_month_rounded, 'Planner'),
                        _buildNavItem(3, Icons.kitchen_outlined, Icons.kitchen_rounded, 'Fridge'),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 1.0, curve: Curves.easeOutBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
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
