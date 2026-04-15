import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/locale_provider.dart';
import '../screens/main_shell.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  final bool isFirstLaunch;

  const LanguageSelectionScreen({super.key, this.isFirstLaunch = true});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    final current = ref.read(localeProvider);
    _selectedCode = current?.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final languages = AppLocalizations.languageInfo;

    return Scaffold(
      backgroundColor: AppColors.bgBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Select Your Language',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You can change this later in settings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Language list
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final code = languages.keys.elementAt(index);
                    final (nativeName, englishName, flag) = languages[code]!;
                    final isSelected = _selectedCode == code;

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
                            setState(() => _selectedCode = code);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.cardRadius,
                              ),
                              color: isSelected
                                  ? AppColors.neonTurquoise.withValues(
                                      alpha: 0.1,
                                    )
                                  : AppColors.cardBg,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.neonTurquoise.withValues(
                                        alpha: 0.4,
                                      )
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  flag,
                                  style: const TextStyle(fontSize: 28),
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
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                      ),
                                      if (nativeName != englishName) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          englishName,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
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
                                      size: 16,
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
              // Continue button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _selectedCode == null
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              _onContinue();
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: _selectedCode != null
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.neonTurquoise,
                                    AppColors.electricBlue,
                                  ],
                                )
                              : null,
                          color: _selectedCode == null
                              ? AppColors.cardBg
                              : null,
                          boxShadow: _selectedCode != null
                              ? [
                                  BoxShadow(
                                    color: AppColors.electricBlue.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Continue',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: _selectedCode != null
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                letterSpacing: 1.1,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    final code = _selectedCode!;
    ref.read(localeProvider.notifier).setLocale(Locale(code));

    if (widget.isFirstLaunch) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
