import 'package:dj_deckify/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every supported locale has a complete catalog', () {
    final cs = lookupAppLocalizations(const Locale('cs'));
    for (final locale in AppLocalizations.supportedLocales) {
      final l = lookupAppLocalizations(locale);
      expect(l.partyTagline, isNotEmpty, reason: '$locale');
      expect(l.trackAdded('X'), contains('X'), reason: '$locale');
      if (locale.languageCode != 'cs' && locale.languageCode != 'sk') {
        expect(l.partyIntro, isNot(cs.partyIntro), reason: '$locale is untranslated');
      }
    }
  });

  testWidgets('Arabic lays out right-to-left', (tester) async {
    late TextDirection dir;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        dir = Directionality.of(context);
        return Text(context.l10n.queueEmpty);
      }),
    ));
    expect(dir, TextDirection.rtl);
    expect(find.text('قائمة الانتظار فارغة'), findsOneWidget);
  });
}
