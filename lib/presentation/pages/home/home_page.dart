import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_chipher_app/presentation/pages/media/media_view_page.dart';
import 'package:ios_chipher_app/presentation/pages/settings/settings_page.dart';

/// Главная страница приложения
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // В реальном приложении здесь будет использоваться GetAllMediaUseCase
    // через провайдер состояния

    // Временная заглушка для демонстрации интерфейса
    final demoItems = List.generate(
      20,
      (index) => {
        'id': 'item_$index',
        'isImage': index % 3 != 0, // Каждый третий элемент - видео
        'name': 'File_${index + 1}.${index % 3 == 0 ? 'mp4' : 'jpg'}',
      },
    );

    // Метод для добавления медиа
    void handleAddMedia() {
      // В реальном приложении здесь будет использоваться ImportMediaUseCase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Функция добавления будет реализована позже'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Метод для обработки нажатия на элемент
    void handleItemTap(Map<String, dynamic> item) {
      // В реальном приложении здесь будет открываться страница просмотра
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => MediaViewPage(
                mediaId: item['id'] as String,
                isImage: item['isImage'] as bool,
              ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Media Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body:
          demoItems.isEmpty
              ? const Center(
                child: Text(
                  'Нет файлов. Нажмите "+" чтобы добавить файлы',
                  textAlign: TextAlign.center,
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: demoItems.length,
                itemBuilder: (context, index) {
                  final item = demoItems[index];
                  return GestureDetector(
                    onTap: () => handleItemTap(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Здесь в реальном приложении будет отображаться миниатюра
                          Icon(
                            item['isImage'] as bool
                                ? Icons.image
                                : Icons.video_file,
                            size: 40,
                            color: Colors.grey[600],
                          ),

                          // Индикатор типа файла
                          if (!(item['isImage'] as bool))
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: handleAddMedia,
        tooltip: 'Добавить медиафайл',
        child: const Icon(Icons.add),
      ),
    );
  }
}
