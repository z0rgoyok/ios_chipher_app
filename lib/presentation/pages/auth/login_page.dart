import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_chipher_app/core/theme/app_theme.dart';

/// Страница входа в приложение
class LoginPage extends HookConsumerWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final isLoading = useState(false);

    // Временная заглушка для авторизации - в реальном приложении
    // здесь будет использоваться LoginUseCase
    void handleLogin() {
      isLoading.value = true;

      // Имитация загрузки
      Future.delayed(const Duration(seconds: 1), () {
        isLoading.value = false;
        onLoginSuccess();
      });
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
                  'Secure Media Vault',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Защитите ваши фото и видео',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),

                // Поле ввода пароля
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    hintText: 'Введите ваш пароль',
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
                            : const Text(
                              'Войти',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                // Кнопка биометрии - в реальном приложении
                OutlinedButton.icon(
                  onPressed:
                      isLoading.value
                          ? null
                          : () {
                            // В реальном приложении здесь будет проверка биометрии
                            handleLogin();
                          },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Вход по биометрии'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
