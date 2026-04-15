const Map<String, String> stringsDe = {
  // Allgemein
  'appName': 'Nox VPN',
  'cancel': 'Abbrechen',
  'save': 'Speichern',
  'retry': 'Erneut versuchen',
  'remove': 'Entfernen',
  'import': 'Importieren',
  'error': 'Fehler',
  'clearAll': 'Alle entfernen',

  // Navigation
  'navHome': 'Startseite',
  'navServers': 'Server',
  'navSettings': 'Einstellungen',
  'navAbout': 'Info',

  // App-Leiste
  'protected': 'Geschützt',
  'notProtected': 'Nicht geschützt',

  // Verbindungs-Hub
  'tapToConnect': 'Zum Verbinden tippen',
  'requesting': 'Wird angefordert...',
  'securing': 'Wird gesichert...',
  'secured': 'Gesichert',
  'disconnecting': 'Wird getrennt',
  'connectNow': 'JETZT VERBINDEN',
  'connecting': 'VERBINDE...',
  'disconnect': 'TRENNEN',
  'disconnectingBtn': 'WIRD GETRENNT...',
  'retryBtn': 'ERNEUT VERSUCHEN',
  'serverLoading': 'Server wird noch geladen. Bitte warten...',

  // Verbindungsstatistiken
  'download': 'Download',
  'upload': 'Upload',
  'totalDown': 'Gesamt herunter',
  'totalUp': 'Gesamt hoch',

  // Startbildschirm
  'quickConnect': 'Schnellverbindung',
  'seeAll': 'Alle anzeigen',
  'active': 'Aktiv',
  'settingUpTunnel': 'Sicherer Tunnel wird aufgebaut...',

  // Serverliste
  'searchServers': 'Server suchen...',
  'noServersFound': 'Keine Server gefunden',
  'removeServer': 'Server entfernen',
  'removeServerConfirm': '"@city" entfernen?',

  // Einstellungen
  'sectionWireguardConfig': 'WIREGUARD-KONFIGURATION',
  'importConfFile': '.conf-Datei importieren',
  'pasteWireguardConfig': 'WireGuard-Konfiguration einfügen',
  'sectionConnection': 'VERBINDUNG',
  'killSwitch': 'Kill Switch',
  'killSwitchDesc': 'Gesamten Datenverkehr blockieren, wenn VPN getrennt wird',
  'autoConnect': 'Automatisch verbinden',
  'autoConnectDesc': 'Beim App-Start automatisch verbinden',
  'sectionSplitTunnel': 'SPLIT-TUNNELING',
  'splitTunneling': 'Split-Tunneling',
  'splitTunnelDesc': 'Apps vom VPN-Tunnel ausschließen',
  'appsExcluded': '@count App(s) ausgeschlossen',
  'sectionDns': 'DNS-EINSTELLUNGEN',
  'cloudflare': 'Cloudflare',
  'google': 'Google',
  'custom': 'Benutzerdefiniert',
  'setCustomDns': 'Benutzerdefinierte DNS-Server festlegen',
  'customDns': 'Benutzerdefiniertes DNS',
  'primaryDnsHint': 'Primäres DNS (z.\u00A0B. 1.1.1.1)',
  'secondaryDnsHint': 'Sekundäres DNS (z.\u00A0B. 1.0.0.1)',
  'sectionAppInfo': 'APP-INFO',
  'protocol': 'Protokoll',
  'protocolDesc': 'WireGuard (ChaCha20, Curve25519)',
  'serverNameHint': 'Servername (z.\u00A0B. US-Server)',
  'configPlaceholder':
      '[Interface]\nPrivateKey = ...\nAddress = ...\n\n[Peer]\nPublicKey = ...\nEndpoint = ...',
  'importedServer': 'Importierter Server',
  'importSuccess': '"@name" erfolgreich importiert!',
  'invalidConfig': 'Ungültige WireGuard-Konfigurationsdatei',

  // Split-Tunnel-Ansicht
  'searchApps': 'Apps suchen...',
  'splitTunnelBypass': 'Ausgewählte Apps umgehen den VPN-Tunnel',

  // Profil / Info
  'wireguard': 'WireGuard',
  'fast': 'Schnell',
  'noLogs': 'Keine Logs',
  'encrypted': 'Verschlüsselt',
  'wireguardProtocol': 'WireGuard-Protokoll',
  'wireguardProtocolDesc':
      'WireGuard ist ein äußerst einfaches, aber schnelles und modernes VPN, das modernste Kryptographie verwendet.',
  'fastLightweight': 'Schnell & Leichtgewichtig',
  'fastLightweightDesc':
      'WireGuard läuft mit minimalem Overhead und ist damit eines der schnellsten verfügbaren VPN-Protokolle.',
  'modernCrypto': 'Moderne Kryptographie',
  'modernCryptoDesc':
      'Verwendet Curve25519, ChaCha20, Poly1305, BLAKE2s und SipHash24 für maximale Sicherheit.',
  'privacyPolicy': 'Datenschutzrichtlinie',
  'contactUs': 'Kontakt',
  'github': 'GitHub',

  // WARP-Status
  'warpRegistering': 'WARP (Registrierung...)',
  'warpTapToRetry': 'WARP (Zum Wiederholen tippen)',
  'warpAuto': 'WARP (Automatisch)',
  'warpFailed': 'WARP-Registrierung fehlgeschlagen. Internetverbindung prüfen.',

  // VPN-Fehler
  'vpnPermissionDenied': 'VPN-Berechtigung verweigert',
  'tunnelFailed': 'Tunnel nach @count Versuchen fehlgeschlagen',
  'connectionFailed': 'Verbindung nach @count Versuchen fehlgeschlagen',

  // Sprache
  'language': 'Sprache',
  'selectLanguage': 'Sprache auswählen',
  'chooseLanguageDesc': 'Sie können dies später in den Einstellungen ändern',
  'continueBtn': 'Weiter',
};
