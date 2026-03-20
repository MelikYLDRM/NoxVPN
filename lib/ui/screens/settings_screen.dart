import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/server_provider.dart';
import '../../services/wireguard_config_parser.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 16),
          // Header
          const Row(
            children: [
              Icon(Icons.settings, color: AppColors.neonTurquoise, size: 28),
              SizedBox(width: 12),
              Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Import WireGuard Config
          _buildSectionTitle('WIREGUARD CONFIG'),
          _buildImportButton(context, ref),
          _buildPasteConfigButton(context, ref),
          const SizedBox(height: 20),

          // Protocol info
          _buildSectionTitle('PROTOCOL'),
          _buildInfoTile(
            icon: Icons.shield_rounded,
            title: 'WireGuard',
            subtitle: 'Fast, modern, and secure VPN protocol',
          ),
          const SizedBox(height: 20),

          // Connection
          _buildSectionTitle('CONNECTION'),
          _buildSwitchTile(
            icon: Icons.block,
            title: 'Kill Switch',
            subtitle: 'Block internet if VPN drops',
            value: settings.killSwitchEnabled,
            onChanged: notifier.setKillSwitch,
          ),
          _buildSwitchTile(
            icon: Icons.flash_on,
            title: 'Auto Connect',
            subtitle: 'Connect on app startup',
            value: settings.autoConnect,
            onChanged: notifier.setAutoConnect,
          ),
          const SizedBox(height: 20),

          // DNS
          _buildSectionTitle('DNS SETTINGS'),
          _buildDnsTile(
            title: 'Cloudflare',
            subtitle: '1.1.1.1 / 1.0.0.1',
            isSelected: settings.dnsMode == 'cloudflare',
            onTap: () => notifier.setDnsMode('cloudflare'),
          ),
          _buildDnsTile(
            title: 'Google',
            subtitle: '8.8.8.8 / 8.8.4.4',
            isSelected: settings.dnsMode == 'google',
            onTap: () => notifier.setDnsMode('google'),
          ),
          _buildDnsTile(
            title: 'Custom',
            subtitle: settings.dnsMode == 'custom'
                ? '${settings.customDns1 ?? "..."} / ${settings.customDns2 ?? "..."}'
                : 'Set custom DNS servers',
            isSelected: settings.dnsMode == 'custom',
            onTap: () {
              notifier.setDnsMode('custom');
              _showCustomDnsDialog(context, ref);
            },
          ),
          const SizedBox(height: 20),

          // App info
          _buildSectionTitle('APP INFO'),
          _buildInfoTile(
            icon: Icons.info_outline,
            title: AppConstants.appName,
            subtitle: 'Version ${AppConstants.appVersion}',
          ),
          _buildInfoTile(
            icon: Icons.code,
            title: 'Demo Mode',
            subtitle: AppConstants.kDemoMode ? 'Enabled' : 'Disabled',
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonTurquoise, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonTurquoise, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.neonTurquoise,
          ),
        ],
      ),
    );
  }

  Widget _buildDnsTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? AppColors.neonTurquoise.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? AppColors.neonTurquoise.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.dns,
              color: isSelected ? AppColors.neonTurquoise : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.neonTurquoise,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _importConfigFile(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [AppColors.neonTurquoise, AppColors.electricBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_outlined, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Import .conf File',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasteConfigButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showPasteConfigDialog(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.paste_rounded, color: AppColors.neonTurquoise, size: 22),
            SizedBox(width: 10),
            Text(
              'Paste WireGuard Config',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
      _processConfig(context, ref, content, result.files.single.name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
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
    final parsed = WireGuardConfigParser.parse(content);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid WireGuard config file'),
          backgroundColor: Colors.redAccent,
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
        content: Text('Server "$name" imported successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPasteConfigDialog(BuildContext context, WidgetRef ref) {
    final configController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgDark,
        title: const Text(
          'Paste WireGuard Config',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Server name (e.g., US Server)',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: AppColors.neonTurquoise),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: configController,
                style:
                    const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
                maxLines: 12,
                decoration: InputDecoration(
                  hintText: '[Interface]\nPrivateKey = ...\nAddress = ...\n\n[Peer]\nPublicKey = ...\nEndpoint = ...',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: AppColors.neonTurquoise),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final name = nameController.text.isNotEmpty
                  ? nameController.text
                  : 'Imported Server';
              _processConfig(context, ref, configController.text, name);
            },
            child: const Text(
              'Import',
              style: TextStyle(color: AppColors.neonTurquoise),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgDark,
        title: const Text('Custom DNS', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dns1Controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Primary DNS (e.g., 1.1.1.1)',
                hintStyle: TextStyle(color: Colors.grey[600]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.neonTurquoise),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dns2Controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Secondary DNS (e.g., 1.0.0.1)',
                hintStyle: TextStyle(color: Colors.grey[600]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.neonTurquoise),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setCustomDns(dns1Controller.text, dns2Controller.text);
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.neonTurquoise),
            ),
          ),
        ],
      ),
    );
  }
}
