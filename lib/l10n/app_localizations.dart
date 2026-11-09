import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('gu'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('nb'),
    Locale('nl'),
    Locale('or'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('pt', 'PT'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sv'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// Live party bar above the decks: now playing title and queue length
  ///
  /// In cs, this message translates to:
  /// **'{title} · fronta: {count}'**
  String partyBarStatus(String title, int count);

  /// Party label with its join code when nothing plays
  ///
  /// In cs, this message translates to:
  /// **'Party {code}'**
  String partyWithCode(String code);

  /// Button that adds another DJ deck
  ///
  /// In cs, this message translates to:
  /// **'PŘIDAT DECK'**
  String get addDeck;

  /// Empty deck hint
  ///
  /// In cs, this message translates to:
  /// **'Přetáhni track sem'**
  String get deckDropHint;

  /// Empty deck during a party
  ///
  /// In cs, this message translates to:
  /// **'Čeká na frontu'**
  String get deckWaitingForQueue;

  /// Tooltip when effects are unavailable for a stream
  ///
  /// In cs, this message translates to:
  /// **'DSP nedostupné (HLS stream)'**
  String get dspUnavailable;

  /// Tooltip for beat-synced effects without tempo
  ///
  /// In cs, this message translates to:
  /// **'BPM neznámé'**
  String get bpmUnknown;

  /// Generic error title
  ///
  /// In cs, this message translates to:
  /// **'Chyba'**
  String get genericError;

  /// Party start screen headline
  ///
  /// In cs, this message translates to:
  /// **'Tvůj telefon je DJ. Reproduktor je jen reproduktor.'**
  String get partyTagline;

  /// Party start screen explanation
  ///
  /// In cs, this message translates to:
  /// **'Hosté naskenují QR, hledají a hlasují v prohlížeči – bez appky a bez účtu. Fronta žije u tebe, zvuk pošleš přes AirPlay nebo Bluetooth.'**
  String get partyIntro;

  /// Text field label
  ///
  /// In cs, this message translates to:
  /// **'Název party'**
  String get partyNameLabel;

  /// Button that starts a party
  ///
  /// In cs, this message translates to:
  /// **'ZALOŽIT PARTY'**
  String get startParty;

  /// Back button
  ///
  /// In cs, this message translates to:
  /// **'ZPĚT'**
  String get back;

  /// Tooltip of the QR button
  ///
  /// In cs, this message translates to:
  /// **'QR pro hosty'**
  String get qrForGuests;

  /// Tooltip of the end party button
  ///
  /// In cs, this message translates to:
  /// **'Ukončit party'**
  String get endParty;

  /// Confirmation dialog title
  ///
  /// In cs, this message translates to:
  /// **'Ukončit party?'**
  String get endPartyQuestion;

  /// Confirmation dialog body
  ///
  /// In cs, this message translates to:
  /// **'Hosté se odpojí a fronta se smaže.'**
  String get endPartyWarning;

  /// Dialog button: no
  ///
  /// In cs, this message translates to:
  /// **'NE'**
  String get no;

  /// Dialog button: end the party
  ///
  /// In cs, this message translates to:
  /// **'UKONČIT'**
  String get endAction;

  /// Tab: queue
  ///
  /// In cs, this message translates to:
  /// **'FRONTA'**
  String get tabQueue;

  /// Tab: guests
  ///
  /// In cs, this message translates to:
  /// **'HOSTÉ'**
  String get tabGuests;

  /// Tab: search
  ///
  /// In cs, this message translates to:
  /// **'HLEDAT'**
  String get tabSearch;

  /// Button that copies the join link
  ///
  /// In cs, this message translates to:
  /// **'KOPÍROVAT ODKAZ'**
  String get copyLink;

  /// Shown when the party queue is empty
  ///
  /// In cs, this message translates to:
  /// **'Fronta je prázdná'**
  String get queueEmpty;

  /// Nothing plays yet but the queue has tracks
  ///
  /// In cs, this message translates to:
  /// **'Připraveno – zmáčkni ▶'**
  String get readyPressPlay;

  /// Who added the playing track
  ///
  /// In cs, this message translates to:
  /// **'přidal(a) {name}'**
  String addedBy(String name);

  /// Switch label: keep the party going when the queue runs dry
  ///
  /// In cs, this message translates to:
  /// **'NEKONČIT'**
  String get keepGoing;

  /// Feature name: lock the BPM range
  ///
  /// In cs, this message translates to:
  /// **'Mood lock'**
  String get moodLock;

  /// Mood lock dialog hint
  ///
  /// In cs, this message translates to:
  /// **'Skladby mimo rozsah zůstanou ve frontě, ale nezahrají se samy.'**
  String get moodLockHint;

  /// Dialog button: turn the mood lock off
  ///
  /// In cs, this message translates to:
  /// **'VYPNOUT'**
  String get turnOff;

  /// Dialog button: lock the BPM range
  ///
  /// In cs, this message translates to:
  /// **'ZAMKNOUT'**
  String get lockAction;

  /// Empty queue tab
  ///
  /// In cs, this message translates to:
  /// **'Zatím nic. Přidej skladbu nebo ukaž hostům QR.'**
  String get queueEmptyHint;

  /// Swipe-to-veto background label
  ///
  /// In cs, this message translates to:
  /// **'VETO'**
  String get vetoBadge;

  /// Menu item: veto a track
  ///
  /// In cs, this message translates to:
  /// **'Veto'**
  String get vetoMenu;

  /// Menu item
  ///
  /// In cs, this message translates to:
  /// **'Hrát hned'**
  String get playNow;

  /// Menu item: pin as next
  ///
  /// In cs, this message translates to:
  /// **'Hrát příští'**
  String get playNext;

  /// Menu item: unpin
  ///
  /// In cs, this message translates to:
  /// **'Odepnout'**
  String get unpin;

  /// Empty guests tab
  ///
  /// In cs, this message translates to:
  /// **'Zatím nikdo nedorazil'**
  String get noGuestsYet;

  /// Guest list subtitle for a co-DJ; weight is the vote multiplier
  ///
  /// In cs, this message translates to:
  /// **'co-DJ · hlas ×{weight}, může dát veto'**
  String coDjSubtitle(int weight);

  /// Guest list subtitle for a regular guest (a guest, not the host)
  ///
  /// In cs, this message translates to:
  /// **'host'**
  String get guestRole;

  /// Tooltip
  ///
  /// In cs, this message translates to:
  /// **'Odebrat co-DJ'**
  String get removeCoDj;

  /// Tooltip
  ///
  /// In cs, this message translates to:
  /// **'Povýšit na co-DJ'**
  String get promoteCoDj;

  /// Tooltip: ban a guest
  ///
  /// In cs, this message translates to:
  /// **'Zablokovat'**
  String get blockGuest;

  /// Search field hint
  ///
  /// In cs, this message translates to:
  /// **'Hledat na SoundCloudu…'**
  String get searchSoundCloudHint;

  /// Snackbar after adding a track
  ///
  /// In cs, this message translates to:
  /// **'„{title}“ přidáno'**
  String trackAdded(String title);

  /// Smart playlist search hint
  ///
  /// In cs, this message translates to:
  /// **'Interpret nebo Interpret - Song...'**
  String get playlistSearchHint;

  /// Smart playlist empty state
  ///
  /// In cs, this message translates to:
  /// **'Zadej kapelu nebo song'**
  String get playlistIdle;

  /// Smart playlist loading
  ///
  /// In cs, this message translates to:
  /// **'Hledám „{query}“…'**
  String searchingFor(String query);

  /// Smart playlist section header
  ///
  /// In cs, this message translates to:
  /// **'Podobné (seřazeno dle BPM)'**
  String get similarByBpm;

  /// Error with details
  ///
  /// In cs, this message translates to:
  /// **'Chyba: {message}'**
  String errorWithMessage(String message);

  /// Host toast
  ///
  /// In cs, this message translates to:
  /// **'Nenašel jsem další skladbu – přidej nějakou do fronty'**
  String get toastNoNextTrack;

  /// Host toast
  ///
  /// In cs, this message translates to:
  /// **'Vybírám další skladbu…'**
  String get toastPickingNext;

  /// Host toast
  ///
  /// In cs, this message translates to:
  /// **'Nejde přehrát „{title}“ – přeskakuju'**
  String toastCannotPlay(String title);

  /// Party could not connect to the relay server
  ///
  /// In cs, this message translates to:
  /// **'Relay nedostupný: {error}'**
  String relayUnavailable(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'fi',
    'fr',
    'gu',
    'he',
    'hi',
    'hr',
    'hu',
    'id',
    'it',
    'ja',
    'kn',
    'ko',
    'ml',
    'mr',
    'ms',
    'nb',
    'nl',
    'or',
    'pa',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sv',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sv':
      return AppLocalizationsSv();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
