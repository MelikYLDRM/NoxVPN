import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final l = AppLocalizations.of(context);
    final vpnState = ref.read(vpnStateProvider);
    final selectedServer = ref.read(selectedServerProvider);

    if (selectedServer.serverPublicKey.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.hourglass_bottom, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(l.serverLoading),
            ],
          ),
          backgroundColor: AppColors.warningOrange,
          margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    if (vpnState.isConnected) {
      ref.read(vpnStateProvider.notifier).disconnect();
    } else if (!vpnState.isConnecting && !vpnState.isDisconnecting) {
      ref.read(vpnStateProvider.notifier).connect(selectedServer);
    }
  }

  void _syncAnimations(VpnState vpnState) {
    if (vpnState.isConnected) {
      if (!_waveController.isAnimating) _waveController.repeat();
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_waveController.isAnimating) {
        _waveController.stop();
        _waveController.reset();
      }
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnState = ref.watch(vpnStateProvider);
    final theme = Theme.of(context);

    // Listen for state changes to manage animations and feedback
    ref.listen(vpnStateProvider, (prev, next) {
      if (next.status == VpnConnectionStatus.error &&
          next.errorMessage != null) {
        HapticFeedback.heavyImpact();
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(l.resolve(next.errorMessage!))),
              ],
            ),
            backgroundColor: AppColors.errorRed,
            margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
          ),
        );
      }
      if (prev?.status == VpnConnectionStatus.connecting &&
          next.status == VpnConnectionStatus.connected) {
        HapticFeedback.heavyImpact();
      }
      _syncAnimations(next);
    });

    // Initial sync
    _syncAnimations(vpnState);

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
            animation: Listenable.merge([_waveController, _pulseController]),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _handleTap,
                child: Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isConnected
                            ? AppColors.primaryGradient
                            : isError
                            ? LinearGradient(
                                colors: [
                                  AppColors.errorRed,
                                  AppColors.errorRed.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF3A3A5A),
                                  Color(0xFF1E1E2E),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: isConnected
                            ? [
                                BoxShadow(
                                  color: AppColors.neonTurquoise.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ]
                            : isError
                            ? [
                                BoxShadow(
                                  color: AppColors.errorRed.withValues(
                                    alpha: 0.4,
                                  ),
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
                              isConnected
                                  ? Icons.shield
                                  : isError
                                  ? Icons.error_outline
                                  : Icons.shield_outlined,
                              size: 50,
                              color: isConnected || isError
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            _statusText(vpnState.status),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isConnected || isError
                                  ? Colors.white
                                  : AppColors.textSecondary,
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
          ),
        ),
        const SizedBox(height: 20),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: isLoading
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    _handleTap();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: isLoading
                      ? [Colors.grey[700]!, Colors.grey[800]!]
                      : isError
                      ? [
                          AppColors.errorRed,
                          AppColors.errorRed.withValues(alpha: 0.7),
                        ]
                      : isConnected
                      ? [const Color(0xFF3A3A5A), const Color(0xFF1E1E2E)]
                      : [AppColors.neonTurquoise, AppColors.electricBlue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: !isConnected && !isLoading && !isError
                    ? [
                        BoxShadow(
                          color: AppColors.electricBlue.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                _buttonText(vpnState.status),
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _statusText(VpnConnectionStatus status) {
    final l = AppLocalizations.of(context);
    switch (status) {
      case VpnConnectionStatus.disconnected:
        return l.tapToConnect;
      case VpnConnectionStatus.requestingPermission:
        return l.requesting;
      case VpnConnectionStatus.connecting:
        return l.securing;
      case VpnConnectionStatus.connected:
        return l.secured;
      case VpnConnectionStatus.disconnecting:
        return l.disconnecting;
      case VpnConnectionStatus.error:
        return l.error;
    }
  }

  String _buttonText(VpnConnectionStatus status) {
    final l = AppLocalizations.of(context);
    switch (status) {
      case VpnConnectionStatus.disconnected:
        return l.connectNow;
      case VpnConnectionStatus.requestingPermission:
      case VpnConnectionStatus.connecting:
        return l.connecting;
      case VpnConnectionStatus.connected:
        return l.disconnect;
      case VpnConnectionStatus.disconnecting:
        return l.disconnectingBtn;
      case VpnConnectionStatus.error:
        return l.retryBtn;
    }
  }
}
