const Map<String, String> stringsFr = {
  // Général
  'appName': 'Nox VPN',
  'cancel': 'Annuler',
  'save': 'Enregistrer',
  'retry': 'Réessayer',
  'remove': 'Supprimer',
  'import': 'Importer',
  'error': 'Erreur',
  'clearAll': 'Tout effacer',

  // Navigation
  'navHome': 'Accueil',
  'navServers': 'Serveurs',
  'navSettings': 'Paramètres',
  'navAbout': 'À propos',

  // Barre d'application
  'protected': 'Protégé',
  'notProtected': 'Non protégé',

  // Hub de connexion
  'tapToConnect': 'Appuyez pour connecter',
  'requesting': 'Requête en cours...',
  'securing': 'Sécurisation...',
  'secured': 'Sécurisé',
  'disconnecting': 'Déconnexion',
  'connectNow': 'CONNECTER',
  'connecting': 'CONNEXION...',
  'disconnect': 'DÉCONNECTER',
  'disconnectingBtn': 'DÉCONNEXION...',
  'retryBtn': 'RÉESSAYER',
  'serverLoading':
      'Le serveur est en cours de chargement. Veuillez patienter...',

  // Statistiques de connexion
  'download': 'Téléchargement',
  'upload': 'Envoi',
  'totalDown': 'Total reçu',
  'totalUp': 'Total envoyé',

  // Écran d'accueil
  'quickConnect': 'Connexion rapide',
  'seeAll': 'Tout voir',
  'active': 'Actif',
  'settingUpTunnel': 'Mise en place du tunnel sécurisé...',

  // Liste des serveurs
  'searchServers': 'Rechercher des serveurs...',
  'noServersFound': 'Aucun serveur trouvé',
  'removeServer': 'Supprimer le serveur',
  'removeServerConfirm': 'Supprimer "@city" ?',

  // Paramètres
  'sectionWireguardConfig': 'CONFIGURATION WIREGUARD',
  'importConfFile': 'Importer un fichier .conf',
  'pasteWireguardConfig': 'Coller la configuration WireGuard',
  'sectionConnection': 'CONNEXION',
  'killSwitch': 'Kill Switch',
  'killSwitchDesc': 'Bloquer tout le trafic si le VPN se déconnecte',
  'autoConnect': 'Connexion automatique',
  'autoConnectDesc':
      "Se connecter automatiquement au démarrage de l'application",
  'sectionSplitTunnel': 'TUNNELING FRACTIONNÉ',
  'splitTunneling': 'Tunneling fractionné',
  'splitTunnelDesc': 'Exclure des applications du tunnel VPN',
  'appsExcluded': '@count application(s) exclue(s)',
  'sectionDns': 'PARAMÈTRES DNS',
  'cloudflare': 'Cloudflare',
  'google': 'Google',
  'custom': 'Personnalisé',
  'setCustomDns': 'Définir des serveurs DNS personnalisés',
  'customDns': 'DNS personnalisé',
  'primaryDnsHint': 'DNS primaire (ex. 1.1.1.1)',
  'secondaryDnsHint': 'DNS secondaire (ex. 1.0.0.1)',
  'sectionAppInfo': "INFOS SUR L'APPLICATION",
  'protocol': 'Protocole',
  'protocolDesc': 'WireGuard (ChaCha20, Curve25519)',
  'serverNameHint': 'Nom du serveur (ex. Serveur US)',
  'configPlaceholder':
      '[Interface]\nPrivateKey = ...\nAddress = ...\n\n[Peer]\nPublicKey = ...\nEndpoint = ...',
  'importedServer': 'Serveur importé',
  'importSuccess': '"@name" importé avec succès !',
  'invalidConfig': 'Fichier de configuration WireGuard invalide',

  // Panneau de tunneling fractionné
  'searchApps': 'Rechercher des applications...',
  'splitTunnelBypass':
      'Les applications sélectionnées contourneront le tunnel VPN',

  // Profil / À propos
  'wireguard': 'WireGuard',
  'fast': 'Rapide',
  'noLogs': 'Sans journaux',
  'encrypted': 'Chiffré',
  'wireguardProtocol': 'Protocole WireGuard',
  'wireguardProtocolDesc':
      'WireGuard est un VPN extrêmement simple, rapide et moderne qui utilise une cryptographie de pointe.',
  'fastLightweight': 'Rapide et léger',
  'fastLightweightDesc':
      "WireGuard fonctionne avec un minimum de surcharge, ce qui en fait l'un des protocoles VPN les plus rapides disponibles.",
  'modernCrypto': 'Cryptographie moderne',
  'modernCryptoDesc':
      'Utilise Curve25519, ChaCha20, Poly1305, BLAKE2s et SipHash24 pour une sécurité maximale.',
  'privacyPolicy': 'Politique de confidentialité',
  'contactUs': 'Nous contacter',
  'github': 'GitHub',

  // États WARP
  'warpRegistering': 'WARP (Enregistrement...)',
  'warpTapToRetry': 'WARP (Appuyez pour réessayer)',
  'warpAuto': 'WARP (Automatique)',
  'warpFailed':
      "Échec de l'enregistrement WARP. Vérifiez la connexion Internet.",

  // Erreurs VPN
  'vpnPermissionDenied': 'Autorisation VPN refusée',
  'tunnelFailed': 'Tunnel échoué après @count tentatives',
  'connectionFailed': 'Connexion échouée après @count tentatives',

  // Langue
  'language': 'Langue',
  'selectLanguage': 'Sélectionnez votre langue',
  'chooseLanguageDesc':
      'Vous pourrez modifier cela plus tard dans les paramètres',
  'continueBtn': 'Continuer',
};
