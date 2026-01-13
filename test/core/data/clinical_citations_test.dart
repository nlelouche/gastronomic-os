import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/data/clinical_citations.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

void main() {
  group('ClinicalCitations Localization Tests', () {
    testWidgets('returns English citation for ID 1', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final text = ClinicalCitations.get(context, 1);
              return Text(text, textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Label reading'), findsOneWidget);
    });

    testWidgets('returns Spanish citation for ID 1', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Builder(
            builder: (context) {
              final text = ClinicalCitations.get(context, 1);
              return Text(text, textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Lectura de etiquetas'), findsOneWidget);
    });

    testWidgets('returns fallback for unknown ID', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final text = ClinicalCitations.get(context, 99999);
              return Text(text, textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Citation #99999'), findsOneWidget);
    });
  });
}
