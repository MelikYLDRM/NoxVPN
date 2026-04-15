import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/vpn_settings.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, VpnSettings>((
  ref,
) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<VpnSettings> {
  SettingsNotifier() : super(VpnSettings.defaults()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = VpnSettings(
        killSwitchEnabled: prefs.getBool('killSwitch') ?? false,
        dnsMode: prefs.getString('dnsMode') ?? 'cloudflare',
        customDns1: prefs.getString('customDns1'),
        customDns2: prefs.getString('customDns2'),
        autoConnect: prefs.getBool('autoConnect') ?? false,
        excludedApps: prefs.getStringList('excludedApps') ?? [],
      );
    } catch (_) {
      // Keep defaults on error
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool('killSwitch', state.killSwitchEnabled),
      prefs.setString('dnsMode', state.dnsMode),
      prefs.setBool('autoConnect', state.autoConnect),
      prefs.setStringList('excludedApps', state.excludedApps),
      if (state.customDns1 != null)
        prefs.setString('customDns1', state.customDns1!)
      else
        prefs.remove('customDns1'),
      if (state.customDns2 != null)
        prefs.setString('customDns2', state.customDns2!)
      else
        prefs.remove('customDns2'),
    ]);
  }

  Future<void> setKillSwitch(bool enabled) async {
    state = state.copyWith(killSwitchEnabled: enabled);
    await _saveToPrefs();
  }

  Future<void> setDnsMode(String mode) async {
    state = state.copyWith(dnsMode: mode);
    await _saveToPrefs();
  }

  Future<void> setCustomDns(String? dns1, String? dns2) async {
    state = state.copyWith(customDns1: dns1, customDns2: dns2);
    await _saveToPrefs();
  }

  Future<void> setAutoConnect(bool enabled) async {
    state = state.copyWith(autoConnect: enabled);
    await _saveToPrefs();
  }

  Future<void> setExcludedApps(List<String> apps) async {
    state = state.copyWith(excludedApps: apps);
    await _saveToPrefs();
  }

  Future<void> toggleExcludedApp(String packageName) async {
    final current = List<String>.from(state.excludedApps);
    if (current.contains(packageName)) {
      current.remove(packageName);
    } else {
      current.add(packageName);
    }
    state = state.copyWith(excludedApps: current);
    await _saveToPrefs();
  }
}
