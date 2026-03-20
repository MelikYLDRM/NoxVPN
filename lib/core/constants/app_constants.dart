class AppConstants {
  static const String vpnChannelName = 'com.melikyldrm.noxvpn/vpn';
  static const String vpnEventChannelName = 'com.melikyldrm.noxvpn/vpn_status';

  static const Duration statsPollingInterval = Duration(seconds: 1);
  static const Duration connectionTimeout = Duration(seconds: 30);

  static const bool kDemoMode = false;

  static const String appName = 'Nox VPN';
  static const String appVersion = '1.0.0';
}
