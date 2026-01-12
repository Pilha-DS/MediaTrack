import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/media_item.dart';
import 'models/quick_url.dart';
import 'models/search_history.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MediaItemAdapter());
  Hive.registerAdapter(MediaTypeAdapter());
  Hive.registerAdapter(MediaStatusAdapter());
  Hive.registerAdapter(QuickUrlAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  try {
    final box = await Hive.openBox<MediaItem>('mediaItems');
    // Verificar se há itens com schema antigo e migrar
    for (var key in box.keys) {
      try {
        final item = box.get(key);
        if (item != null) {
          // Garantir que os novos campos existam
          if (!item.isFavorite) {
            item.isFavorite = false;
          }
          if (item.favoriteChapters.isEmpty) {
            item.favoriteChapters = [];
          }
          await box.put(key, item);
        }
      } catch (e) {
        // Se houver erro ao ler um item, deleta o box e recria
        await Hive.deleteBoxFromDisk('mediaItems');
        await Hive.openBox<MediaItem>('mediaItems');
        break;
      }
    }
  } catch (e) {
    // Se houver erro (ex: schema incompatível), deleta e recria o box
    try {
      await Hive.deleteBoxFromDisk('mediaItems');
    } catch (_) {}
    await Hive.openBox<MediaItem>('mediaItems');
  }
  try {
    await Hive.openBox<QuickUrl>('quickUrls');
  } catch (e) {
    try {
      await Hive.deleteBoxFromDisk('quickUrls');
    } catch (_) {}
    await Hive.openBox<QuickUrl>('quickUrls');
  }
  try {
    await Hive.openBox<SearchHistory>('searchHistory');
  } catch (e) {
    try {
      await Hive.deleteBoxFromDisk('searchHistory');
    } catch (_) {}
    await Hive.openBox<SearchHistory>('searchHistory');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
