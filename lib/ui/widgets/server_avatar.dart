import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/server_config.dart';

class ServerAvatar extends StatelessWidget {
  final ServerConfig server;
  final double size;

  const ServerAvatar({super.key, required this.server, this.size = 36});

  @override
  Widget build(BuildContext context) {
    if (server.isWarp) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.warpGradient,
        ),
        child: Icon(Icons.cloud, color: Colors.white, size: size * 0.55),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.electricBlue.withValues(alpha: 0.2),
      ),
      child: ClipOval(
        child: Image.network(
          server.flagUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              server.countryCode.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.neonTurquoise,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
