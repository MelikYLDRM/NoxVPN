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
    final prefs = await SharedPreferences.getInstance();
    state = VpnSettings(
      killSwitchEnabled: prefs.getBool('killSwitch') ?? false,
      dnsMode: prefs.getString('dnsMode') ?? 'cloudflare',
      customDns1: prefs.getString('customDns1'),
      customDns2: prefs.getString('customDns2'),
      autoConnect: prefs.getBool('autoConnect') ?? false,
    );
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('killSwitch', state.killSwitchEnabled);
    await prefs.setString('dnsMode', state.dnsMode);
    if (state.customDns1 != null) {
      await prefs.setString('customDns1', state.customDns1!);
    }
    if (state.customDns2 != null) {
      await prefs.setString('customDns2', state.customDns2!);
    }
    await prefs.setBool('autoConnect', state.autoConnect);
  }

  void setKillSwitch(bool enabled) {
    state = state.copyWith(killSwitchEnabled: enabled);
    _saveToPrefs();
  }

  void setDnsMode(String mode) {
    state = state.copyWith(dnsMode: mode);
    _saveToPrefs();
  }

  void setCustomDns(String? dns1, String? dns2) {
    state = state.copyWith(customDns1: dns1, customDns2: dns2);
    _saveToPrefs();
  }

  void setAutoConnect(bool enabled) {
    state = state.copyWith(autoConnect: enabled);
    _saveToPrefs();
  }
}
