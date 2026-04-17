class VpnSettings {
  final bool killSwitchEnabled;
  final String dnsMode;
  final String? customDns1;
  final String? customDns2;
  final bool autoConnect;
  final List<String> excludedApps;
  final int keepaliveInterval;
  final bool ipv6Enabled;

  const VpnSettings({
    this.killSwitchEnabled = false,
    this.dnsMode = 'cloudflare',
    this.customDns1,
    this.customDns2,
    this.autoConnect = false,
    this.excludedApps = const [],
    this.keepaliveInterval = 15,
    this.ipv6Enabled = false,
  });

  factory VpnSettings.defaults() => const VpnSettings();

  List<String> get activeDnsServers {
    switch (dnsMode) {
      case 'cloudflare':
        return ['1.1.1.1', '1.0.0.1'];
      case 'google':
        return ['8.8.8.8', '8.8.4.4'];
      case 'quad9':
        return ['9.9.9.9', '149.112.112.112'];
      case 'auto':
        // Will be resolved by DNS benchmark; fallback to Cloudflare
        return ['1.1.1.1', '1.0.0.1'];
      case 'custom':
        return [
          if (customDns1 != null && customDns1!.isNotEmpty) customDns1!,
          if (customDns2 != null && customDns2!.isNotEmpty) customDns2!,
        ];
      default:
        return ['1.1.1.1', '1.0.0.1'];
    }
  }

  List<String> get activeAllowedIPs {
    if (ipv6Enabled) {
      return ['0.0.0.0/0', '::/0'];
    }
    return ['0.0.0.0/0'];
  }

  VpnSettings copyWith({
    bool? killSwitchEnabled,
    String? dnsMode,
    Object? customDns1 = _sentinel,
    Object? customDns2 = _sentinel,
    bool? autoConnect,
    List<String>? excludedApps,
    int? keepaliveInterval,
    bool? ipv6Enabled,
  }) {
    return VpnSettings(
      killSwitchEnabled: killSwitchEnabled ?? this.killSwitchEnabled,
      dnsMode: dnsMode ?? this.dnsMode,
      customDns1: customDns1 == _sentinel
          ? this.customDns1
          : customDns1 as String?,
      customDns2: customDns2 == _sentinel
          ? this.customDns2
          : customDns2 as String?,
      autoConnect: autoConnect ?? this.autoConnect,
      excludedApps: excludedApps ?? this.excludedApps,
      keepaliveInterval: keepaliveInterval ?? this.keepaliveInterval,
      ipv6Enabled: ipv6Enabled ?? this.ipv6Enabled,
    );
  }

  static const _sentinel = Object();
}
