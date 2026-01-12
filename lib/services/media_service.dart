import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_item.dart';

class MediaService {
  static Box<MediaItem> get _box => Hive.box<MediaItem>('mediaItems');
  
  static Box<MediaItem> get box => _box;

  static List<MediaItem> getAllItems() {
    return _box.values.toList(growable: false);
  }

  static List<MediaItem> getItemsByType(MediaType? type) {
    if (type == null) return getAllItems();
    return _box.values.where((item) => item.type == type).toList(growable: false);
  }

  static MediaItem? getItem(String id) {
    return _box.get(id);
  }

  static Future<void> addItem(MediaItem item) async {
    await _box.put(item.id, item);
  }

  static Future<void> updateItem(MediaItem item) async {
    item.updatedAt = DateTime.now();
    await _box.put(item.id, item);
  }

  static Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }

  static int getItemCount() {
    return _box.length;
  }

  static int getCompletedCount() {
    int count = 0;
    for (final item in _box.values) {
      if (item.isCompleted) count++;
    }
    return count;
  }
}
