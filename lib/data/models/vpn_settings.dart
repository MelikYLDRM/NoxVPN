class VpnSettings {
  final bool killSwitchEnabled;
  final String dnsMode;
  final String? customDns1;
  final String? customDns2;
  final bool autoConnect;

  const VpnSettings({
    this.killSwitchEnabled = false,
    this.dnsMode = 'cloudflare',
    this.customDns1,
    this.customDns2,
    this.autoConnect = false,
  });

  factory VpnSettings.defaults() => const VpnSettings();

  List<String> get activeDnsServers {
    switch (dnsMode) {
      case 'cloudflare':
        return ['1.1.1.1', '1.0.0.1'];
      case 'google':
        return ['8.8.8.8', '8.8.4.4'];
      case 'custom':
        return [
          if (customDns1 != null && customDns1!.isNotEmpty) customDns1!,
          if (customDns2 != null && customDns2!.isNotEmpty) customDns2!,
        ];
      default:
        return ['1.1.1.1', '1.0.0.1'];
    }
  }

  VpnSettings copyWith({
    bool? killSwitchEnabled,
    String? dnsMode,
    String? customDns1,
    String? customDns2,
    bool? autoConnect,
  }) {
    return VpnSettings(
      killSwitchEnabled: killSwitchEnabled ?? this.killSwitchEnabled,
      dnsMode: dnsMode ?? this.dnsMode,
      customDns1: customDns1 ?? this.customDns1,
      customDns2: customDns2 ?? this.customDns2,
      autoConnect: autoConnect ?? this.autoConnect,
    );
  }
}
