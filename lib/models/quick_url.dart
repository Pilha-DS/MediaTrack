import 'package:hive/hive.dart';

part 'quick_url.g.dart';

@HiveType(typeId: 3)
class QuickUrl extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String url;

  @HiveField(3)
  DateTime createdAt;

  QuickUrl({
    required this.id,
    required this.name,
    required this.url,
    required this.createdAt,
  });
}
