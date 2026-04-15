import 'package:flutter/widgets.dart';

import 'strings_ar.dart';
import 'strings_de.dart';
import 'strings_en.dart';
import 'strings_es.dart';
import 'strings_fr.dart';
import 'strings_hi.dart';
import 'strings_pt.dart';
import 'strings_ru.dart';
import 'strings_tr.dart';
import 'strings_zh.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tr'),
    Locale('de'),
    Locale('fr'),
    Locale('es'),
    Locale('ru'),
    Locale('ar'),
    Locale('pt'),
    Locale('hi'),
    Locale('zh'),
  ];

  /// Language metadata: code -> (native name, english name, flag emoji)
  static const Map<String, (String, String, String)> languageInfo = {
    'en': ('English', 'English', '🇬🇧'),
    'tr': ('Türkçe', 'Turkish', '🇹🇷'),
    'de': ('Deutsch', 'German', '🇩🇪'),
    'fr': ('Français', 'French', '🇫🇷'),
    'es': ('Español', 'Spanish', '🇪🇸'),
    'ru': ('Русский', 'Russian', '🇷🇺'),
    'ar': ('العربية', 'Arabic', '🇸🇦'),
    'pt': ('Português', 'Portuguese', '🇧🇷'),
    'hi': ('हिन्दी', 'Hindi', '🇮🇳'),
    'zh': ('中文', 'Chinese', '🇨🇳'),
  };

  late final Map<String, String> _strings = _loadStrings();

  Map<String, String> _loadStrings() {
    switch (locale.languageCode) {
      case 'tr':
        return stringsTr;
      case 'de':
        return stringsDe;
      case 'fr':
        return stringsFr;
      case 'es':
        return stringsEs;
      case 'ru':
        return stringsRu;
      case 'ar':
        return stringsAr;
      case 'pt':
        return stringsPt;
      case 'hi':
        return stringsHi;
      case 'zh':
        return stringsZh;
      case 'en':
      default:
        return stringsEn;
    }
  }

  String get(String key) => _strings[key] ?? key;

  /// Resolves a string that may be a localization key prefixed with '@'.
  /// Supports '@key' for simple lookups and '@key:param' for parameterized strings.
  /// Returns the input unchanged if it doesn't start with '@'.
  String resolve(String text) {
    if (!text.startsWith('@')) return text;
    final stripped = text.substring(1);
    // Handle parameterized keys like '@tunnelFailed:3'
    final colonIdx = stripped.indexOf(':');
    if (colonIdx != -1) {
      final key = stripped.substring(0, colonIdx);
      final param = stripped.substring(colonIdx + 1);
      return getWithParam(key, '@count', param);
    }
    return get(stripped);
  }

  String getWithParam(String key, String param, String value) {
    final str = _strings[key] ?? key;
    return str.replaceAll(param, value);
  }

  // Convenience accessors
  //-- General
  String get appName => get('appName');
  String get cancel => get('cancel');
  String get save => get('save');
  String get retry => get('retry');
  String get remove => get('remove');
  String get importStr => get('import');
  String get error => get('error');
  String get clearAll => get('clearAll');

  //-- Navigation
  String get navHome => get('navHome');
  String get navServers => get('navServers');
  String get navSettings => get('navSettings');
  String get navAbout => get('navAbout');

  //-- App Bar
  String get protected_ => get('protected');
  String get notProtected => get('notProtected');

  //-- Connection Hub
  String get tapToConnect => get('tapToConnect');
  String get requesting => get('requesting');
  String get securing => get('securing');
  String get secured => get('secured');
  String get disconnecting => get('disconnecting');
  String get connectNow => get('connectNow');
  String get connecting => get('connecting');
  String get disconnect => get('disconnect');
  String get disconnectingBtn => get('disconnectingBtn');
  String get retryBtn => get('retryBtn');
  String get serverLoading => get('serverLoading');

  //-- Stats
  String get download => get('download');
  String get upload => get('upload');
  String get totalDown => get('totalDown');
  String get totalUp => get('totalUp');

  //-- Home
  String get quickConnect => get('quickConnect');
  String get seeAll => get('seeAll');
  String get active => get('active');
  String get settingUpTunnel => get('settingUpTunnel');

  //-- Server List
  String get searchServers => get('searchServers');
  String get noServersFound => get('noServersFound');
  String get removeServer => get('removeServer');
  String removeServerConfirm(String city) =>
      getWithParam('removeServerConfirm', '@city', city);

  //-- Settings
  String get sectionWireguardConfig => get('sectionWireguardConfig');
  String get importConfFile => get('importConfFile');
  String get pasteWireguardConfig => get('pasteWireguardConfig');
  String get sectionConnection => get('sectionConnection');
  String get killSwitch => get('killSwitch');
  String get killSwitchDesc => get('killSwitchDesc');
  String get autoConnect => get('autoConnect');
  String get autoConnectDesc => get('autoConnectDesc');
  String get sectionSplitTunnel => get('sectionSplitTunnel');
  String get splitTunneling => get('splitTunneling');
  String get splitTunnelDesc => get('splitTunnelDesc');
  String appsExcluded(int count) =>
      getWithParam('appsExcluded', '@count', count.toString());
  String get sectionDns => get('sectionDns');
  String get cloudflare => get('cloudflare');
  String get google => get('google');
  String get custom => get('custom');
  String get setCustomDns => get('setCustomDns');
  String get customDns => get('customDns');
  String get primaryDnsHint => get('primaryDnsHint');
  String get secondaryDnsHint => get('secondaryDnsHint');
  String get sectionAppInfo => get('sectionAppInfo');
  String get protocol => get('protocol');
  String get protocolDesc => get('protocolDesc');
  String get serverNameHint => get('serverNameHint');
  String get configPlaceholder => get('configPlaceholder');
  String get importedServer => get('importedServer');
  String importSuccess(String name) =>
      getWithParam('importSuccess', '@name', name);
  String get invalidConfig => get('invalidConfig');

  //-- Split Tunnel
  String get searchApps => get('searchApps');
  String get splitTunnelBypass => get('splitTunnelBypass');

  //-- Profile
  String get wireguard => get('wireguard');
  String get fast => get('fast');
  String get noLogs => get('noLogs');
  String get encrypted => get('encrypted');
  String get wireguardProtocol => get('wireguardProtocol');
  String get wireguardProtocolDesc => get('wireguardProtocolDesc');
  String get fastLightweight => get('fastLightweight');
  String get fastLightweightDesc => get('fastLightweightDesc');
  String get modernCrypto => get('modernCrypto');
  String get modernCryptoDesc => get('modernCryptoDesc');
  String get privacyPolicy => get('privacyPolicy');
  String get contactUs => get('contactUs');
  String get github => get('github');

  //-- WARP
  String get warpRegistering => get('warpRegistering');
  String get warpTapToRetry => get('warpTapToRetry');
  String get warpAuto => get('warpAuto');
  String get warpFailed => get('warpFailed');

  //-- VPN Errors
  String get vpnPermissionDenied => get('vpnPermissionDenied');
  String tunnelFailed(int count) =>
      getWithParam('tunnelFailed', '@count', count.toString());
  String connectionFailed(int count) =>
      getWithParam('connectionFailed', '@count', count.toString());

  //-- Language
  String get language => get('language');
  String get selectLanguage => get('selectLanguage');
  String get chooseLanguageDesc => get('chooseLanguageDesc');
  String get continueBtn => get('continueBtn');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'tr', 'de', 'fr', 'es', 'ru', 'ar', 'pt', 'hi', 'zh']
          .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
