const Map<String, String> stringsEn = {
  // General
  'appName': 'Nox VPN',
  'cancel': 'Cancel',
  'save': 'Save',
  'retry': 'Retry',
  'remove': 'Remove',
  'import': 'Import',
  'error': 'Error',
  'clearAll': 'Clear All',

  // Navigation
  'navHome': 'Home',
  'navServers': 'Servers',
  'navSettings': 'Settings',
  'navAbout': 'About',

  // App Bar
  'protected': 'Protected',
  'notProtected': 'Not Protected',

  // Connection Hub
  'tapToConnect': 'Tap to Connect',
  'requesting': 'Requesting...',
  'securing': 'Securing...',
  'secured': 'Secured',
  'disconnecting': 'Disconnecting',
  'connectNow': 'CONNECT NOW',
  'connecting': 'CONNECTING...',
  'disconnect': 'DISCONNECT',
  'disconnectingBtn': 'DISCONNECTING...',
  'retryBtn': 'RETRY',
  'serverLoading': 'Server is still loading. Please wait...',

  // Connection Stats
  'download': 'Download',
  'upload': 'Upload',
  'totalDown': 'Total Down',
  'totalUp': 'Total Up',

  // Home Screen
  'quickConnect': 'Quick Connect',
  'seeAll': 'See All',
  'active': 'Active',
  'settingUpTunnel': 'Setting up secure tunnel...',

  // Server List
  'searchServers': 'Search servers...',
  'noServersFound': 'No servers found',
  'removeServer': 'Remove Server',
  'removeServerConfirm': 'Remove "@city"?',

  // Settings
  'sectionWireguardConfig': 'WIREGUARD CONFIG',
  'importConfFile': 'Import .conf File',
  'pasteWireguardConfig': 'Paste WireGuard Config',
  'sectionConnection': 'CONNECTION',
  'killSwitch': 'Kill Switch',
  'killSwitchDesc': 'Block all traffic if VPN disconnects',
  'autoConnect': 'Auto Connect',
  'autoConnectDesc': 'Connect automatically on app startup',
  'sectionSplitTunnel': 'SPLIT TUNNELING',
  'splitTunneling': 'Split Tunneling',
  'splitTunnelDesc': 'Exclude apps from VPN tunnel',
  'appsExcluded': '@count app(s) excluded',
  'sectionDns': 'DNS SETTINGS',
  'cloudflare': 'Cloudflare',
  'google': 'Google',
  'custom': 'Custom',
  'setCustomDns': 'Set custom DNS servers',
  'customDns': 'Custom DNS',
  'primaryDnsHint': 'Primary DNS (e.g., 1.1.1.1)',
  'secondaryDnsHint': 'Secondary DNS (e.g., 1.0.0.1)',
  'sectionAppInfo': 'APP INFO',
  'protocol': 'Protocol',
  'protocolDesc': 'WireGuard (ChaCha20, Curve25519)',
  'serverNameHint': 'Server name (e.g., US Server)',
  'configPlaceholder':
      '[Interface]\nPrivateKey = ...\nAddress = ...\n\n[Peer]\nPublicKey = ...\nEndpoint = ...',
  'importedServer': 'Imported Server',
  'importSuccess': '"@name" imported successfully!',
  'invalidConfig': 'Invalid WireGuard config file',

  // Split Tunnel Sheet
  'searchApps': 'Search apps...',
  'splitTunnelBypass': 'Selected apps will bypass the VPN tunnel',

  // Profile / About
  'wireguard': 'WireGuard',
  'fast': 'Fast',
  'noLogs': 'No Logs',
  'encrypted': 'Encrypted',
  'wireguardProtocol': 'WireGuard Protocol',
  'wireguardProtocolDesc':
      'WireGuard is an extremely simple yet fast and modern VPN that utilizes state-of-the-art cryptography.',
  'fastLightweight': 'Fast & Lightweight',
  'fastLightweightDesc':
      'WireGuard runs with minimal overhead, making it one of the fastest VPN protocols available.',
  'modernCrypto': 'Modern Cryptography',
  'modernCryptoDesc':
      'Uses Curve25519, ChaCha20, Poly1305, BLAKE2s, and SipHash24 for maximum security.',
  'privacyPolicy': 'Privacy Policy',
  'contactUs': 'Contact Us',
  'github': 'GitHub',

  // WARP States
  'warpRegistering': 'WARP (Registering...)',
  'warpTapToRetry': 'WARP (Tap to Retry)',
  'warpAuto': 'WARP (Auto)',
  'warpFailed': 'WARP registration failed. Check internet connection.',

  // VPN Errors
  'vpnPermissionDenied': 'VPN permission denied',
  'tunnelFailed': 'Tunnel failed after @count attempts',
  'connectionFailed': 'Connection failed after @count attempts',

  // Language
  'language': 'Language',
  'selectLanguage': 'Select Your Language',
  'chooseLanguageDesc': 'You can change this later in settings',
  'continueBtn': 'Continue',
};
