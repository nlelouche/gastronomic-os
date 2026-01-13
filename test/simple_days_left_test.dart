import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Test simple de inventoryDaysLeft', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            
            // Test directo del método
            print('Testing inventoryDaysLeft...');
            final result = l10n.inventoryDaysLeft(10);
            print('Result: $result');
            
            return Scaffold(
              body: Text(result, textDirection: TextDirection.ltr),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    // Verificar que el texto se renderizó
    expect(find.textContaining('10'), findsOneWidget);
    expect(find.textContaining('left'), findsOneWidget);
  });
}
