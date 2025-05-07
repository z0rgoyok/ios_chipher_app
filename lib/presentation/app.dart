import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_chipher_app/core/constants/app_constants.dart';
import 'package:ios_chipher_app/presentation/pages/auth/login_page.dart';
import 'package:ios_chipher_app/presentation/pages/home/home_page.dart';
import 'package:ios_chipher_app/core/theme/app_theme.dart';

/// Главный виджет приложения
class SecureMediaVaultApp extends HookConsumerWidget {
  const SecureMediaVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // В настоящем приложении здесь будет провайдер состояния аутентификации
    // Например: final authState = ref.watch(authStateProvider);

    // Заглушка для начального этапа разработки
    final isAuthenticated = useState(false);

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru'), Locale('en')],
      debugShowCheckedModeBanner: false,
      home:
          isAuthenticated.value
              ? const HomePage()
              : LoginPage(onLoginSuccess: () => isAuthenticated.value = true),
    );
  }
}
