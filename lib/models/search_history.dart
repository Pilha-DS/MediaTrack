import 'package:hive/hive.dart';

part 'search_history.g.dart';

@HiveType(typeId: 4)
class SearchHistory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String query;

  @HiveField(2)
  DateTime searchedAt;

  SearchHistory({
    required this.id,
    required this.query,
    required this.searchedAt,
  });
}
