import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Test de lógica de días restantes', (WidgetTester tester) async {
    // Crear item con 10 días de vida
    final item = InventoryItem(
      id: '1',
      name: 'Test',
      quantity: 1,
      unit: 'unit',
      expirationDate: DateTime.now().add(const Duration(days: 10)),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              
              // Simular la lógica del widget
              final daysUntil = item.expirationDate!.difference(DateTime.now()).inDays;
              String statusText = '';
              
              if (daysUntil < 0) {
                statusText = l10n.inventoryExpired;
              } else if (daysUntil <= 3) {
                statusText = l10n.inventoryExpiringSoon;
              } else {
                statusText = l10n.inventoryDaysLeft(daysUntil);
              }
              
              print('daysUntil: $daysUntil');
              print('statusText: $statusText');
              
              return Center(
                child: Text(statusText, textDirection: TextDirection.ltr),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    // El texto debería contener "d left"
    expect(find.textContaining('d left'), findsOneWidget);
  });
}
