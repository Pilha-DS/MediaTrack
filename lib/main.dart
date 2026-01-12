import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/media_item.dart';
import 'models/quick_url.dart';
import 'models/search_history.dart';
import 'models/app_settings.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MediaItemAdapter());
  Hive.registerAdapter(MediaTypeAdapter());
  Hive.registerAdapter(MediaStatusAdapter());
  Hive.registerAdapter(QuickUrlAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
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
  try {
    await Hive.openBox<AppSettings>('appSettings');
    // Criar configurações padrão se não existirem
    final settingsBox = Hive.box<AppSettings>('appSettings');
    if (settingsBox.isEmpty) {
      final defaultSettings = AppSettings();
      await settingsBox.put('settings', defaultSettings);
    }
  } catch (e) {
    try {
      await Hive.deleteBoxFromDisk('appSettings');
    } catch (_) {}
    await Hive.openBox<AppSettings>('appSettings');
    final settingsBox = Hive.box<AppSettings>('appSettings');
    final defaultSettings = AppSettings();
    await settingsBox.put('settings', defaultSettings);
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Box<AppSettings> _settingsBox;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box<AppSettings>('appSettings');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<AppSettings>>(
      valueListenable: _settingsBox.listenable(),
      builder: (context, box, _) {
        final settings = box.get('settings') ?? AppSettings();

        ThemeMode themeMode;
        switch (settings.themeMode) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;
            break;
          default:
            themeMode = ThemeMode.system;
        }

        return MaterialApp(
          title: '',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: settings.useMaterial3,
            brightness: Brightness.light,
            // Esquema de cores mais suave para o modo claro (um pouco mais escuro)
            colorScheme: ColorScheme.light(
              // Cor primária - roxo suave
              primary: const Color(0xFF7B6BC7),
              onPrimary: Colors.white,
              // Cor secundária - azul suave
              secondary: const Color(0xFF6B9BD6),
              onSecondary: Colors.white,
              // Cor de erro - vermelho suave
              error: const Color(0xFFD67B7B),
              onError: Colors.white,
              // Superfície - cinza muito claro (um pouco mais escuro)
              surface: const Color(0xFFF0F0F0),
              onSurface: const Color(0xFF2D2D2D),
              // Superfície variante - cinza claro
              surfaceVariant: const Color(0xFFE8E8E8),
              onSurfaceVariant: const Color(0xFF5A5A5A),
              // Fundo - branco levemente acinzentado
              background: const Color(0xFFF5F5F5),
              onBackground: const Color(0xFF2D2D2D),
              // Container de cor primária
              primaryContainer: const Color(0xFFE8E4F5),
              onPrimaryContainer: const Color(0xFF4A3D7A),
              // Container de cor secundária
              secondaryContainer: const Color(0xFFE0E8F0),
              onSecondaryContainer: const Color(0xFF3D5A7A),
            ),
            // Tema de card mais suave (um pouco mais escuro)
            cardTheme: CardThemeData(
              elevation: 0,
              color: const Color(0xFFF0F0F0),
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.4),
                  width: 1.0,
                ),
              ),
            ),
            // Tema de AppBar mais suave
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: const Color(0xFF7B6BC7),
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
            // Tema de scaffold mais suave (um pouco mais escuro)
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            // Tema de input mais suave
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF7B6BC7),
                  width: 2,
                ),
              ),
            ),
            // Tema de botão elevado mais suave
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B6BC7),
                foregroundColor: Colors.white,
                elevation: 1,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Tema de botão outlined mais suave
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7B6BC7),
                side: const BorderSide(
                  color: Color(0xFF7B6BC7),
                  width: 1.5,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Tema de floating action button mais suave
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: const Color(0xFF7B6BC7),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            // Tema de divider mais suave
            dividerTheme: DividerThemeData(
              color: Colors.grey.withOpacity(0.2),
              thickness: 1,
            ),
            // Tema de chip mais suave
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xFFF5F5F5),
              labelStyle: const TextStyle(color: Color(0xFF2D2D2D)),
              secondaryLabelStyle: const TextStyle(color: Color(0xFF7B6BC7)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            // Tema de dialog mais suave (um pouco mais escuro)
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFFF0F0F0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titleTextStyle: const TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: const TextStyle(
                color: Color(0xFF5A5A5A),
                fontSize: 16,
              ),
            ),
            // Tema de bottom sheet mais suave (um pouco mais escuro)
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: const Color(0xFFF0F0F0),
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            // Tema de list tile mais suave
            listTileTheme: ListTileThemeData(
              tileColor: Colors.transparent,
              textColor: const Color(0xFF2D2D2D),
              iconColor: const Color(0xFF7B6BC7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: settings.useMaterial3,
            brightness: Brightness.dark,
            // Esquema de cores customizado para tema escuro mais bonito
            colorScheme: ColorScheme.dark(
              // Cor primária - roxo suave e moderno
              primary: const Color(0xFF9C88FF),
              onPrimary: Colors.white,
              // Cor secundária - azul suave
              secondary: const Color(0xFF6C9BD2),
              onSecondary: Colors.white,
              // Cor de erro - vermelho suave
              error: const Color(0xFFFF6B6B),
              onError: Colors.white,
              // Superfície - cinza escuro elegante
              surface: const Color(0xFF1E1E2E),
              onSurface: const Color(0xFFE0E0E0),
              // Superfície variante - um pouco mais clara
              surfaceVariant: const Color(0xFF2D2D3D),
              onSurfaceVariant: const Color(0xFFB0B0B0),
              // Fundo - quase preto mas não totalmente
              background: const Color(0xFF121212),
              onBackground: const Color(0xFFE0E0E0),
              // Container de cor primária
              primaryContainer: const Color(0xFF3D2E5C),
              onPrimaryContainer: const Color(0xFFE8D5FF),
              // Container de cor secundária
              secondaryContainer: const Color(0xFF2A3D4F),
              onSecondaryContainer: const Color(0xFFD0E4F0),
            ),
            // Tema de card melhorado - mais suave para não cansar os olhos
            cardTheme: CardThemeData(
              elevation: 0,
              color:
                  const Color(0xFF1A1A2A), // Um pouco mais escuro que surface
              shadowColor: Colors.transparent, // Sem sombras no modo escuro
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.15), // Borda mais visível
                  width: 1.0, // Borda mais espessa
                ),
              ),
            ),
            // Tema de AppBar melhorado
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: const Color(0xFF1E1E2E),
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
            // Tema de scaffold melhorado
            scaffoldBackgroundColor: const Color(0xFF121212),
            // Tema de input melhorado
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF2D2D3D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF9C88FF),
                  width: 2,
                ),
              ),
            ),
            // Tema de botão elevado melhorado
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C88FF),
                foregroundColor: Colors.white,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Tema de botão outlined melhorado
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9C88FF),
                side: const BorderSide(
                  color: Color(0xFF9C88FF),
                  width: 1.5,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Tema de floating action button melhorado
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: const Color(0xFF9C88FF),
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            // Tema de divider melhorado
            dividerTheme: DividerThemeData(
              color: Colors.white.withOpacity(0.1),
              thickness: 1,
            ),
            // Tema de chip melhorado
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xFF2D2D3D),
              labelStyle: const TextStyle(color: Color(0xFFE0E0E0)),
              secondaryLabelStyle: const TextStyle(color: Color(0xFF9C88FF)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Tema de dialog melhorado
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1E1E2E),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titleTextStyle: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 16,
              ),
            ),
            // Tema de bottom sheet melhorado
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: const Color(0xFF1E1E2E),
              elevation: 8,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            // Tema de list tile melhorado
            listTileTheme: ListTileThemeData(
              tileColor: Colors.transparent,
              textColor: const Color(0xFFE0E0E0),
              iconColor: const Color(0xFF9C88FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          themeMode: themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
