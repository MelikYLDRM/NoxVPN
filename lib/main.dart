import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'providers/server_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/vpn_provider.dart';
import 'ui/screens/language_selection_screen.dart';
import 'ui/screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: NovaVPNApp()));
}

class NovaVPNApp extends ConsumerStatefulWidget {
  const NovaVPNApp({super.key});

  @override
  ConsumerState<NovaVPNApp> createState() => _NovaVPNAppState();
}

class _NovaVPNAppState extends ConsumerState<NovaVPNApp> {
  @override
  void initState() {
    super.initState();
    _checkAutoConnect();
  }

  Future<void> _checkAutoConnect() async {
    if (!mounted) return;

    final warpState = ref.read(warpProvider);
    if (warpState.status == WarpStatus.idle ||
        warpState.status == WarpStatus.registering) {
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        final current = ref.read(warpProvider);
        if (current.status == WarpStatus.registered ||
            current.status == WarpStatus.failed) {
          break;
        }
      }
    }

    if (!mounted) return;

    final settings = ref.read(settingsProvider);
    if (!settings.autoConnect) return;

    final server = ref.read(selectedServerProvider);
    if (server.serverPublicKey.isNotEmpty) {
      ref.read(vpnStateProvider.notifier).connect(server);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final hasSelected = ref.watch(hasSelectedLocaleProvider);

    return MaterialApp(
      title: 'Nox VPN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: hasSelected.when(
        data: (selected) => selected
            ? const MainShell()
            : const LanguageSelectionScreen(),
        loading: () => const Scaffold(
          backgroundColor: AppColors.bgBlack,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.neonTurquoise),
          ),
        ),
        error: (_, __) => const MainShell(),
      ),
    );
  }
}
