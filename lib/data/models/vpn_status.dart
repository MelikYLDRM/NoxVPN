import 'server_config.dart';

enum VpnConnectionStatus {
  disconnected,
  requestingPermission,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnState {
  final VpnConnectionStatus status;
  final ServerConfig? activeServer;
  final String? errorMessage;
  final DateTime? connectedSince;

  const VpnState({
    this.status = VpnConnectionStatus.disconnected,
    this.activeServer,
    this.errorMessage,
    this.connectedSince,
  });

  factory VpnState.disconnected() => const VpnState();

  bool get isConnected => status == VpnConnectionStatus.connected;
  bool get isConnecting =>
      status == VpnConnectionStatus.connecting ||
      status == VpnConnectionStatus.requestingPermission;
  bool get isDisconnecting => status == VpnConnectionStatus.disconnecting;

  VpnState copyWith({
    VpnConnectionStatus? status,
    ServerConfig? activeServer,
    String? errorMessage,
    DateTime? connectedSince,
    bool clearError = false,
    bool clearServer = false,
    bool clearConnectedSince = false,
  }) {
    return VpnState(
      status: status ?? this.status,
      activeServer: clearServer ? null : (activeServer ?? this.activeServer),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      connectedSince: clearConnectedSince
          ? null
          : (connectedSince ?? this.connectedSince),
    );
  }
}
