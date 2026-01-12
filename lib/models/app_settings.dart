import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 5)
class AppSettings extends HiveObject {
  @HiveField(0)
  String themeMode; // 'system', 'light', 'dark'

  @HiveField(1)
  bool useMaterial3;

  AppSettings({
    this.themeMode = 'system',
    this.useMaterial3 = true,
  });
}
