import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/features/inventory/presentation/widgets/inventory_item_card.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

void main() {
  group('InventoryItemCard Tests', () {
    testWidgets('Displays expired localized status correctly', (WidgetTester tester) async {
      final expiredItem = InventoryItem(
        id: '1',
        name: 'Milk',
        quantity: 1.0,
        unit: 'L',
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: InventoryItemCard(
              item: expiredItem,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Expired'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('Displays expiring soon localized status correctly', (WidgetTester tester) async {
      final soonItem = InventoryItem(
        id: '2',
        name: 'Yogurt',
        quantity: 2.0,
        unit: 'cups',
        expirationDate: DateTime.now().add(const Duration(days: 2)),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: InventoryItemCard(
              item: soonItem,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Caduca pronto'), findsOneWidget);
    });

    testWidgets('Displays days left localized status correctly', (WidgetTester tester) async {
      final safeItem = InventoryItem(
        id: '3',
        name: 'Cheese',
        quantity: 500,
        unit: 'g',
        expirationDate: DateTime.now().add(const Duration(days: 10)),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: InventoryItemCard(
              item: safeItem,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // El texto debería contener "d left" (puede ser 9d o 10d por timing)
      expect(find.textContaining('d left'), findsOneWidget);
      expect(find.text('Cheese'), findsOneWidget);
    });
  });
}
