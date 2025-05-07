import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_chipher_app/core/theme/app_theme.dart';
import 'package:ios_chipher_app/presentation/pages/home/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Страница входа в приложение
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // В реальном приложении здесь будут использоваться провайдеры состояния
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final isLoading = useState(false);
    final l10n = AppLocalizations.of(context)!;

    // Обработчик входа
    Future<void> handleLogin() async {
      if (passwordController.text.isEmpty) {
        return;
      }

      isLoading.value = true;

      // Имитация задержки для демонстрации
      await Future.delayed(const Duration(seconds: 1));

      isLoading.value = false;

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Лого и название
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appTagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),

                // Поле ввода пароля
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    hintText: l10n.passwordHint,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        isPasswordVisible.value = !isPasswordVisible.value;
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible.value,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => handleLogin(),
                ),
                const SizedBox(height: 24),

                // Кнопка входа
                ElevatedButton(
                  onPressed: isLoading.value ? null : handleLogin,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child:
                        isLoading.value
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              l10n.login,
                              style: const TextStyle(fontSize: 16),
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed:
                      isLoading.value
                          ? null
                          : () {
                            // В реальном приложении здесь будет проверка биометрии
                            handleLogin();
                          },
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.biometricLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
