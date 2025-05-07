import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Страница настроек приложения
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // В реальном приложении здесь будут использоваться провайдеры состояния

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          const _SettingsSectionHeader(title: 'Безопасность'),

          // Переключатель биометрии
          SwitchListTile(
            title: const Text('Биометрическая аутентификация'),
            subtitle: const Text('Использовать отпечаток пальца или Face ID'),
            value: true, // В реальном приложении будет из провайдера
            onChanged: (value) {
              // В реальном приложении будет использоваться соответствующий use case
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Биометрия включена' : 'Биометрия отключена',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          // Смена пароля
          ListTile(
            title: const Text('Изменить пароль'),
            leading: const Icon(Icons.lock_outline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // В реальном приложении будет открываться диалог смены пароля
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Функция будет реализована позже'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(),
          const _SettingsSectionHeader(title: 'Приложение'),

          // Переключатель темы
          SwitchListTile(
            title: const Text('Темная тема'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              // В реальном приложении будет переключение темы
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Темная тема включена' : 'Светлая тема включена',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          // Очистка кэша
          ListTile(
            title: const Text('Очистить кэш'),
            subtitle: const Text('Удалить временные файлы'),
            leading: const Icon(Icons.cleaning_services_outlined),
            onTap: () {
              // В реальном приложении будет очистка кэша
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Кэш очищен'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(),
          const _SettingsSectionHeader(title: 'Информация'),

          // Версия приложения
          ListTile(
            title: const Text('Версия приложения'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),

          // Политика конфиденциальности
          ListTile(
            title: const Text('Политика конфиденциальности'),
            leading: const Icon(Icons.privacy_tip_outlined),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // В реальном приложении будет открываться политика
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Функция будет реализована позже'),
                  duration: Duration(seconds: 2),
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
              label: const Text('Выйти из приложения'),
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
