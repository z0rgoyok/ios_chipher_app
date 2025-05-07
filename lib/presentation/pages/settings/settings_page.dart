import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Страница настроек приложения
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // В реальном приложении здесь будут использоваться провайдеры состояния
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _SettingsSectionHeader(title: l10n.securitySection),

          // Переключатель биометрии
          SwitchListTile(
            title: Text(l10n.biometricAuth),
            subtitle: Text(l10n.biometricAuthDesc),
            value: true, // В реальном приложении будет из провайдера
            onChanged: (value) {
              // В реальном приложении будет использоваться соответствующий use case
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? l10n.biometricEnabled : l10n.biometricDisabled,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          // Смена пароля
          ListTile(
            title: Text(l10n.changePassword),
            leading: const Icon(Icons.lock_outline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // В реальном приложении будет открываться диалог смены пароля
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.functionNotImplemented),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(),
          _SettingsSectionHeader(title: l10n.appSection),

          // Переключатель темы
          SwitchListTile(
            title: Text(l10n.darkTheme),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              // В реальном приложении будет переключение темы
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? l10n.darkThemeEnabled : l10n.lightThemeEnabled,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          // Очистка кэша
          ListTile(
            title: Text(l10n.clearCache),
            subtitle: Text(l10n.clearCacheDesc),
            leading: const Icon(Icons.cleaning_services_outlined),
            onTap: () {
              // В реальном приложении будет очистка кэша
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.cacheCleared),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(),
          _SettingsSectionHeader(title: l10n.infoSection),

          // Версия приложения
          ListTile(
            title: Text(l10n.appVersion),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),

          // Политика конфиденциальности
          ListTile(
            title: Text(l10n.privacyPolicy),
            leading: const Icon(Icons.privacy_tip_outlined),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // В реальном приложении будет открываться политика
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.functionNotImplemented),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(),

          // Кнопка выхода
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // В реальном приложении будет использоваться провайдер для логаута
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Виджет заголовка секции настроек
class _SettingsSectionHeader extends StatelessWidget {
  final String title;

  const _SettingsSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
