import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/server_provider.dart';
import '../../services/wireguard_config_parser.dart';
import '../../services/wireguard_platform_channel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
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
                Icons.tune_rounded,
                color: AppColors.neonTurquoise,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(l.navSettings, style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          _buildSectionTitle(context, l.sectionWireguardConfig),
          _buildImportButton(context, ref),
          const SizedBox(height: 6),
          _buildPasteConfigButton(context, ref),
          const SizedBox(height: AppSpacing.xxl),

          _buildSectionTitle(context, l.sectionConnection),
          _buildSwitchTile(
            context: context,
            icon: Icons.shield_rounded,
            title: l.killSwitch,
            subtitle: l.killSwitchDesc,
            value: settings.killSwitchEnabled,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              notifier.setKillSwitch(val);
            },
          ),
          _buildSwitchTile(
            context: context,
            icon: Icons.flash_on_rounded,
            title: l.autoConnect,
            subtitle: l.autoConnectDesc,
            value: settings.autoConnect,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              notifier.setAutoConnect(val);
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          _buildSectionTitle(context, l.sectionSplitTunnel),
          _buildSplitTunnelTile(context, ref, settings.excludedApps),
          const SizedBox(height: AppSpacing.xxl),

          _buildSectionTitle(context, l.sectionDns),
          _buildDnsTile(
            context: context,
            title: l.cloudflare,
            subtitle: '1.1.1.1 / 1.0.0.1',
            icon: Icons.cloud_outlined,
            isSelected: settings.dnsMode == 'cloudflare',
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setDnsMode('cloudflare');
            },
          ),
          _buildDnsTile(
            context: context,
            title: l.google,
            subtitle: '8.8.8.8 / 8.8.4.4',
            icon: Icons.language,
            isSelected: settings.dnsMode == 'google',
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setDnsMode('google');
            },
          ),
          _buildDnsTile(
            context: context,
            title: l.custom,
            subtitle: settings.dnsMode == 'custom'
                ? '${settings.customDns1 ?? "..."} / ${settings.customDns2 ?? "..."}'
                : l.setCustomDns,
            icon: Icons.edit_rounded,
            isSelected: settings.dnsMode == 'custom',
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setDnsMode('custom');
              _showCustomDnsDialog(context, ref);
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          _buildSectionTitle(context, l.language.toUpperCase()),
          _buildLanguageTile(context, ref),
          const SizedBox(height: AppSpacing.xxl),

          _buildSectionTitle(context, l.sectionAppInfo),
          _buildInfoTile(
            context: context,
            icon: Icons.info_outline_rounded,
            title: AppConstants.appName,
            subtitle: 'Version ${AppConstants.appVersion}',
          ),
          _buildInfoTile(
            context: context,
            icon: Icons.security_rounded,
            title: l.protocol,
            subtitle: l.protocolDesc,
          ),
          SizedBox(height: AppSpacing.bottomNavHeight + AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final code = currentLocale?.languageCode ?? 'en';
    final info = AppLocalizations.languageInfo[code];
    final (nativeName, _, flag) = info ?? ('English', 'English', '🇬🇧');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: () {
          HapticFeedback.selectionClick();
          _showLanguagePicker(context, ref);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            color: AppColors.cardBg,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonTurquoise.withValues(alpha: 0.1),
                ),
                child: Text(flag, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.language, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(nativeName, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    final currentCode = currentLocale?.languageCode ?? 'en';
    final languages = AppLocalizations.languageInfo;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    const Icon(
                      Icons.translate_rounded,
                      color: AppColors.neonTurquoise,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      AppLocalizations.of(context).language,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: languages.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  itemBuilder: (_, index) {
                    final code = languages.keys.elementAt(index);
                    final (nativeName, englishName, flag) = languages[code]!;
                    final isSelected = code == currentCode;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(localeProvider.notifier)
                                .setLocale(Locale(code));
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.cardRadius,
                              ),
                              color: isSelected
                                  ? AppColors.neonTurquoise.withValues(
                                      alpha: 0.1,
                                    )
                                  : Colors.transparent,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.neonTurquoise.withValues(
                                        alpha: 0.3,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  flag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nativeName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      if (nativeName != englishName)
                                        Text(
                                          englishName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.neonTurquoise,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonTurquoise.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: AppColors.neonTurquoise, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        color: AppColors.cardBg,
        border: Border.all(
          color: value
              ? AppColors.neonTurquoise.withValues(alpha: 0.2)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? AppColors.neonTurquoise.withValues(alpha: 0.15)
                  : AppColors.iconBg,
            ),
            child: Icon(
              icon,
              color: value ? AppColors.neonTurquoise : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSplitTunnelTile(
    BuildContext context,
    WidgetRef ref,
    List<String> excludedApps,
  ) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: () {
          HapticFeedback.selectionClick();
          _showSplitTunnelDialog(context, ref);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            color: AppColors.cardBg,
            border: Border.all(
              color: excludedApps.isNotEmpty
                  ? AppColors.neonTurquoise.withValues(alpha: 0.2)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: excludedApps.isNotEmpty
                      ? AppColors.neonTurquoise.withValues(alpha: 0.15)
                      : AppColors.iconBg,
                ),
                child: Icon(
                  Icons.alt_route_rounded,
                  color: excludedApps.isNotEmpty
                      ? AppColors.neonTurquoise
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.splitTunneling, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(
                      excludedApps.isEmpty
                          ? l.splitTunnelDesc
                          : l.appsExcluded(excludedApps.length),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDnsTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            color: isSelected
                ? AppColors.neonTurquoise.withValues(alpha: 0.08)
                : AppColors.cardBg,
            border: Border.all(
              color: isSelected
                  ? AppColors.neonTurquoise.withValues(alpha: 0.3)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.neonTurquoise.withValues(alpha: 0.15)
                      : AppColors.iconBg,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.neonTurquoise
                      : AppColors.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonTurquoise,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportButton(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: () {
          HapticFeedback.mediumImpact();
          _importConfigFile(context, ref);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            gradient: AppColors.primaryGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.file_upload_outlined, color: Colors.white, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l.importConfFile,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasteConfigButton(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: () {
          HapticFeedback.lightImpact();
          _showPasteConfigDialog(context, ref);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            color: AppColors.cardBg,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.paste_rounded, color: AppColors.neonTurquoise, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.pasteWireguardConfig,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importConfigFile(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      if (!context.mounted) return;
      _processConfig(context, ref, content, result.files.single.name);
    } catch (e) {
      if (context.mounted) {
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.error}: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _processConfig(
    BuildContext context,
    WidgetRef ref,
    String content,
    String fileName,
  ) {
    if (!context.mounted) return;

    final l = AppLocalizations.of(context);
    final parsed = WireGuardConfigParser.parse(content);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.invalidConfig),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final name = fileName.replaceAll('.conf', '').replaceAll('_', ' ');
    final server = WireGuardConfigParser.toServerConfig(parsed, name: name);

    ref.read(importedServersProvider.notifier).addServer(server);
    ref.read(selectedServerProvider.notifier).state = server;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(l.importSuccess(name)),
          ],
        ),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _showSplitTunnelDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _SplitTunnelSheet(),
    );
  }

  void _showPasteConfigDialog(BuildContext context, WidgetRef ref) {
    final configController = TextEditingController();
    final nameController = TextEditingController();
    final l = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.pasteWireguardConfig),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l.serverNameHint,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: configController,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                maxLines: 12,
                decoration: InputDecoration(
                  hintText: l.configPlaceholder,
                  hintStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final name = nameController.text.isNotEmpty
                  ? nameController.text
                  : l.importedServer;
              _processConfig(context, ref, configController.text, name);
            },
            child: Text(
              l.importStr,
              style: const TextStyle(color: AppColors.neonTurquoise),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomDnsDialog(BuildContext context, WidgetRef ref) {
    final dns1Controller = TextEditingController(
      text: ref.read(settingsProvider).customDns1 ?? '',
    );
    final dns2Controller = TextEditingController(
      text: ref.read(settingsProvider).customDns2 ?? '',
    );
    final l = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.customDns),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dns1Controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l.primaryDnsHint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: dns2Controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l.secondaryDnsHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setCustomDns(dns1Controller.text, dns2Controller.text);
              Navigator.pop(context);
            },
            child: Text(
              l.save,
              style: const TextStyle(color: AppColors.neonTurquoise),
            ),
          ),
        ],
      ),
    );
  }
}

// Fixed: ConsumerStatefulWidget instead of taking external WidgetRef
class _SplitTunnelSheet extends ConsumerStatefulWidget {
  const _SplitTunnelSheet();

  @override
  ConsumerState<_SplitTunnelSheet> createState() => _SplitTunnelSheetState();
}

class _SplitTunnelSheetState extends ConsumerState<_SplitTunnelSheet> {
  List<Map<String, String>> _apps = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await WireGuardPlatformChannel().getInstalledApps();
    if (mounted) {
      setState(() {
        _apps = apps;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final excluded = ref.watch(settingsProvider).excludedApps;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    final filteredApps = _search.isEmpty
        ? _apps
        : _apps.where((a) {
            return (a['appName'] ?? '').toLowerCase().contains(
              _search.toLowerCase(),
            );
          }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.alt_route_rounded,
                        color: AppColors.neonTurquoise,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l.splitTunneling,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (excluded.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            ref
                                .read(settingsProvider.notifier)
                                .setExcludedApps([]);
                          },
                          child: Text(
                            l.clearAll,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.errorRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.splitTunnelBypass,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      color: AppColors.cardBg,
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: l.searchApps,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonTurquoise,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filteredApps.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  itemBuilder: (context, index) {
                    final app = filteredApps[index];
                    final pkg = app['packageName'] ?? '';
                    final name = app['appName'] ?? pkg;
                    final isExcluded = excluded.contains(pkg);

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        color: isExcluded
                            ? AppColors.neonTurquoise.withValues(alpha: 0.06)
                            : Colors.transparent,
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.iconBg,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isExcluded
                                    ? AppColors.neonTurquoise
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        title: Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14)),
                        subtitle: Text(
                          pkg,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Switch.adaptive(
                          value: isExcluded,
                          onChanged: (_) {
                            HapticFeedback.selectionClick();
                            ref
                                .read(settingsProvider.notifier)
                                .toggleExcludedApp(pkg);
                          },
                        ),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(settingsProvider.notifier)
                              .toggleExcludedApp(pkg);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
