import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/vpn_status.dart';
import '../../providers/server_provider.dart';
import '../../providers/vpn_provider.dart';
import 'wave_painter.dart';

class ConnectionHub extends ConsumerStatefulWidget {
  const ConnectionHub({super.key});

  @override
  ConsumerState<ConnectionHub> createState() => _ConnectionHubState();
}

class _ConnectionHubState extends ConsumerState<ConnectionHub>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final vpnState = ref.read(vpnStateProvider);
    final selectedServer = ref.read(selectedServerProvider);

    // Don't allow connecting if server has no valid config
    if (selectedServer.serverPublicKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server is still loading. Please wait...'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (vpnState.isConnected) {
      ref.read(vpnStateProvider.notifier).disconnect();
    } else if (!vpnState.isConnecting && !vpnState.isDisconnecting) {
      ref.read(vpnStateProvider.notifier).connect(selectedServer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnState = ref.watch(vpnStateProvider);

    // Show error snackbar
    ref.listen(vpnStateProvider, (prev, next) {
      if (next.status == VpnConnectionStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    // Control wave animation based on VPN state
    if (vpnState.isConnected) {
      if (!_waveController.isAnimating) {
        _waveController.repeat();
      }
    } else {
      if (_waveController.isAnimating) {
        _waveController.stop();
        _waveController.reset();
      }
    }

    final isConnected = vpnState.isConnected;
    final isLoading = vpnState.isConnecting || vpnState.isDisconnecting;
    final isError = vpnState.status == VpnConnectionStatus.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: isConnected
                    ? WavePainter(
                        animationValue: _waveController.value,
                        waveColor: AppColors.neonTurquoise,
                      )
                    : null,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _handleTap,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isConnected
                        ? const LinearGradient(
                            colors: [
                              AppColors.neonTurquoise,
                              AppColors.electricBlue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : isError
                        ? const LinearGradient(
                            colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF3A3A5A), Color(0xFF1E1E2E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: isConnected
                        ? [
                            BoxShadow(
                              color: AppColors.neonTurquoise.withValues(alpha: 0.6),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: AppColors.neonTurquoise,
                            strokeWidth: 3,
                          ),
                        )
                      else
                        Icon(
                          isError ? Icons.error_outline : Icons.shield_rounded,
                          size: 50,
                          color: isConnected || isError
                              ? Colors.white
                              : AppColors.textGrey,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _statusText(vpnState.status),
                        style: TextStyle(
                          color: isConnected || isError
                              ? Colors.white
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: isLoading ? null : _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: isLoading
                    ? [Colors.grey[700]!, Colors.grey[800]!]
                    : isError
                    ? [const Color(0xFFFF4444), const Color(0xFFCC0000)]
                    : [AppColors.neonTurquoise, AppColors.electricBlue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: isConnected || isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.electricBlue.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: Text(
              _buttonText(vpnState.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _statusText(VpnConnectionStatus status) {
    switch (status) {
      case VpnConnectionStatus.disconnected:
        return 'Disconnected';
      case VpnConnectionStatus.requestingPermission:
        return 'Requesting...';
      case VpnConnectionStatus.connecting:
        return 'Connecting';
      case VpnConnectionStatus.connected:
        return 'Connected';
      case VpnConnectionStatus.disconnecting:
        return 'Disconnecting';
      case VpnConnectionStatus.error:
        return 'Error';
    }
  }

  String _buttonText(VpnConnectionStatus status) {
    switch (status) {
      case VpnConnectionStatus.disconnected:
        return 'CONNECT NOW';
      case VpnConnectionStatus.requestingPermission:
      case VpnConnectionStatus.connecting:
        return 'CONNECTING...';
      case VpnConnectionStatus.connected:
        return 'DISCONNECT NOW';
      case VpnConnectionStatus.disconnecting:
        return 'DISCONNECTING...';
      case VpnConnectionStatus.error:
        return 'RETRY';
    }
  }
}
