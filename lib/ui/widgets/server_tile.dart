import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/server_config.dart';

class ServerTile extends StatelessWidget {
  final ServerConfig server;
  final bool isSelected;
  final VoidCallback onTap;

  const ServerTile({
    super.key,
    required this.server,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? AppColors.neonTurquoise.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? AppColors.neonTurquoise.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            _buildServerIcon(server),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server.city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    server.country,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            PingBadge(pingMs: server.estimatedPingMs),
            const SizedBox(width: 10),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.neonTurquoise,
                size: 22,
              )
            else
              Icon(Icons.circle_outlined, color: Colors.grey[600], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildServerIcon(ServerConfig server) {
    if (server.countryCode == 'warp') {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFF48120), Color(0xFFF6821F)],
          ),
        ),
        child: const Icon(Icons.cloud, color: Colors.white, size: 20),
      );
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(alpha: 0.2),
        image: DecorationImage(
          image: NetworkImage(server.flagUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class PingBadge extends StatelessWidget {
  final int pingMs;

  const PingBadge({super.key, required this.pingMs});

  Color get _color {
    if (pingMs < 50) return Colors.greenAccent;
    if (pingMs < 100) return Colors.yellowAccent;
    if (pingMs < 200) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$pingMs ms',
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
