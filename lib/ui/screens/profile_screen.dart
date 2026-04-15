import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        children: [
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                color: AppColors.neonTurquoise,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(l.navAbout, style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 40),

          // App logo
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/noxlogo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              l.appName,
              style: theme.textTheme.displayLarge,
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.neonTurquoise.withValues(alpha: 0.1),
              ),
              child: Text(
                'v${AppConstants.appVersion}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.neonTurquoise,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Feature chips
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureChip(context, Icons.lock_rounded, l.wireguard),
              _buildFeatureChip(context, Icons.speed_rounded, l.fast),
              _buildFeatureChip(
                context,
                Icons.visibility_off_rounded,
                l.noLogs,
              ),
              _buildFeatureChip(context, Icons.security_rounded, l.encrypted),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _buildInfoCard(
            context,
            icon: Icons.lock_outline_rounded,
            title: l.wireguardProtocol,
            description: l.wireguardProtocolDesc,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoCard(
            context,
            icon: Icons.speed_rounded,
            title: l.fastLightweight,
            description: l.fastLightweightDesc,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoCard(
            context,
            icon: Icons.security_rounded,
            title: l.modernCrypto,
            description: l.modernCryptoDesc,
          ),
          const SizedBox(height: AppSpacing.xxl),

          _buildLinkCard(
            context,
            icon: Icons.privacy_tip_outlined,
            title: l.privacyPolicy,
            color: AppColors.electricBlue,
            onTap: () => _launchUrl(
              'https://melikyldrm.github.io/NoxVPN/privacy-policy.html',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLinkCard(
            context,
            icon: Icons.email_outlined,
            title: l.contactUs,
            subtitle: 'melikyildirim2006@gmail.com',
            color: AppColors.warningOrange,
            onTap: () => _launchUrl('mailto:melikyildirim2006@gmail.com'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLinkCard(
            context,
            icon: Icons.code_rounded,
            title: l.github,
            subtitle: 'MelikYLDRM/NoxVPN',
            color: AppColors.successGreen,
            onTap: () => _launchUrl('https://github.com/MelikYLDRM/NoxVPN'),
          ),
          SizedBox(height: AppSpacing.bottomNavHeight + AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.neonTurquoise, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonTurquoise.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: AppColors.neonTurquoise, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.cardBg,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
