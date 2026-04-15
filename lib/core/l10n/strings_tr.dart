const Map<String, String> stringsTr = {
  // General
  'appName': 'Nox VPN',
  'cancel': 'İptal',
  'save': 'Kaydet',
  'retry': 'Tekrar Dene',
  'remove': 'Kaldır',
  'import': 'İçe Aktar',
  'error': 'Hata',
  'clearAll': 'Tümünü Temizle',

  // Navigation
  'navHome': 'Ana Sayfa',
  'navServers': 'Sunucular',
  'navSettings': 'Ayarlar',
  'navAbout': 'Hakkında',

  // App Bar
  'protected': 'Korumalı',
  'notProtected': 'Korumasız',

  // Connection Hub
  'tapToConnect': 'Bağlanmak İçin Dokun',
  'requesting': 'İzin İsteniyor...',
  'securing': 'Güvenli Bağlantı...',
  'secured': 'Güvende',
  'disconnecting': 'Bağlantı Kesiliyor',
  'connectNow': 'BAĞLAN',
  'connecting': 'BAĞLANIYOR...',
  'disconnect': 'BAĞLANTIYI KES',
  'disconnectingBtn': 'KESİLİYOR...',
  'retryBtn': 'TEKRAR DENE',
  'serverLoading': 'Sunucu hâlâ yükleniyor. Lütfen bekleyin...',

  // Connection Stats
  'download': 'İndirme',
  'upload': 'Yükleme',
  'totalDown': 'Toplam İndirme',
  'totalUp': 'Toplam Yükleme',

  // Home Screen
  'quickConnect': 'Hızlı Bağlan',
  'seeAll': 'Tümünü Gör',
  'active': 'Aktif',
  'settingUpTunnel': 'Güvenli tünel kuruluyor...',

  // Server List
  'searchServers': 'Sunucu ara...',
  'noServersFound': 'Sunucu bulunamadı',
  'removeServer': 'Sunucuyu Kaldır',
  'removeServerConfirm': '"@city" kaldırılsın mı?',

  // Settings
  'sectionWireguardConfig': 'WIREGUARD YAPILANDIRMASI',
  'importConfFile': '.conf Dosyası İçe Aktar',
  'pasteWireguardConfig': 'WireGuard Yapılandırması Yapıştır',
  'sectionConnection': 'BAĞLANTI',
  'killSwitch': 'Kill Switch',
  'killSwitchDesc': 'VPN kesilirse tüm trafiği engelle',
  'autoConnect': 'Otomatik Bağlan',
  'autoConnectDesc': 'Uygulama açılınca otomatik bağlan',
  'sectionSplitTunnel': 'BÖLÜNMÜŞ TÜNEL',
  'splitTunneling': 'Bölünmüş Tünel',
  'splitTunnelDesc': 'Uygulamaları VPN tünelinden hariç tut',
  'appsExcluded': '@count uygulama hariç tutuldu',
  'sectionDns': 'DNS AYARLARI',
  'cloudflare': 'Cloudflare',
  'google': 'Google',
  'custom': 'Özel',
  'setCustomDns': 'Özel DNS sunucuları ayarla',
  'customDns': 'Özel DNS',
  'primaryDnsHint': 'Birincil DNS (ör. 1.1.1.1)',
  'secondaryDnsHint': 'İkincil DNS (ör. 1.0.0.1)',
  'sectionAppInfo': 'UYGULAMA BİLGİSİ',
  'protocol': 'Protokol',
  'protocolDesc': 'WireGuard (ChaCha20, Curve25519)',
  'serverNameHint': 'Sunucu adı (ör. ABD Sunucusu)',
  'configPlaceholder':
      '[Interface]\nPrivateKey = ...\nAddress = ...\n\n[Peer]\nPublicKey = ...\nEndpoint = ...',
  'importedServer': 'İçe Aktarılan Sunucu',
  'importSuccess': '"@name" başarıyla içe aktarıldı!',
  'invalidConfig': 'Geçersiz WireGuard yapılandırma dosyası',

  // Split Tunnel Sheet
  'searchApps': 'Uygulama ara...',
  'splitTunnelBypass': 'Seçilen uygulamalar VPN tünelini atlayacak',

  // Profile / About
  'wireguard': 'WireGuard',
  'fast': 'Hızlı',
  'noLogs': 'Kayıt Yok',
  'encrypted': 'Şifreli',
  'wireguardProtocol': 'WireGuard Protokolü',
  'wireguardProtocolDesc':
      'WireGuard, en son kriptografi tekniklerini kullanan son derece basit, hızlı ve modern bir VPN protokolüdür.',
  'fastLightweight': 'Hızlı ve Hafif',
  'fastLightweightDesc':
      'WireGuard minimum kaynak kullanımı ile çalışır ve mevcut en hızlı VPN protokollerinden biridir.',
  'modernCrypto': 'Modern Kriptografi',
  'modernCryptoDesc':
      'Maksimum güvenlik için Curve25519, ChaCha20, Poly1305, BLAKE2s ve SipHash24 kullanır.',
  'privacyPolicy': 'Gizlilik Politikası',
  'contactUs': 'Bize Ulaşın',
  'github': 'GitHub',

  // WARP States
  'warpRegistering': 'WARP (Kaydediliyor...)',
  'warpTapToRetry': 'WARP (Tekrar Denemek İçin Dokun)',
  'warpAuto': 'WARP (Otomatik)',
  'warpFailed': 'WARP kaydı başarısız. İnternet bağlantınızı kontrol edin.',

  // VPN Errors
  'vpnPermissionDenied': 'VPN izni reddedildi',
  'tunnelFailed': '@count denemeden sonra tünel başarısız oldu',
  'connectionFailed': '@count denemeden sonra bağlantı başarısız oldu',

  // Language
  'language': 'Dil',
  'selectLanguage': 'Dilinizi Seçin',
  'chooseLanguageDesc': 'Bunu daha sonra ayarlardan değiştirebilirsiniz',
  'continueBtn': 'Devam Et',
};
