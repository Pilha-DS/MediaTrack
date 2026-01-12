import 'package:hive/hive.dart';

part 'media_item.g.dart';

@HiveType(typeId: 0)
enum MediaType {
  @HiveField(0)
  serie,
  @HiveField(1)
  filme,
  @HiveField(2)
  livro,
  @HiveField(3)
  jogo,
  @HiveField(4)
  podcast,
  @HiveField(5)
  anime,
  @HiveField(6)
  webtoon,
}

@HiveType(typeId: 1)
class MediaItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  MediaType type;

  @HiveField(3)
  int currentSeason;

  @HiveField(4)
  int currentEpisode;

  @HiveField(5)
  int totalSeasons;

  @HiveField(6)
  int totalEpisodes;

  @HiveField(7)
  int currentChapter;

  @HiveField(8)
  int totalChapters;

  @HiveField(9)
  int currentPage;

  @HiveField(10)
  int totalPages;

  @HiveField(11)
  double rating;

  @HiveField(12)
  String notes;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  @HiveField(15)
  bool isCompleted;

  MediaItem({
    required this.id,
    required this.title,
    required this.type,
    this.currentSeason = 0,
    this.currentEpisode = 0,
    this.totalSeasons = 0,
    this.totalEpisodes = 0,
    this.currentChapter = 0,
    this.totalChapters = 0,
    this.currentPage = 0,
    this.totalPages = 0,
    this.rating = 0.0,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
  });

  double get progress {
    switch (type) {
      case MediaType.serie:
      case MediaType.anime:
        if (totalSeasons == 0 || totalEpisodes == 0) return 0.0;
        int totalWatched = (currentSeason - 1) * totalEpisodes + currentEpisode;
        int totalAvailable = totalSeasons * totalEpisodes;
        return (totalWatched / totalAvailable).clamp(0.0, 1.0);
      case MediaType.filme:
        return isCompleted ? 1.0 : 0.0;
      case MediaType.livro:
        if (totalPages == 0) return 0.0;
        return (currentPage / totalPages).clamp(0.0, 1.0);
      case MediaType.jogo:
        return isCompleted ? 1.0 : 0.0;
      case MediaType.podcast:
        if (totalEpisodes == 0) return 0.0;
        return (currentEpisode / totalEpisodes).clamp(0.0, 1.0);
      case MediaType.webtoon:
        if (totalPages == 0) return 0.0;
        return (currentPage / totalPages).clamp(0.0, 1.0);
    }
  }

  String get progressText {
    switch (type) {
      case MediaType.serie:
      case MediaType.anime:
        return 'T${currentSeason} E${currentEpisode} / T${totalSeasons} E${totalEpisodes}';
      case MediaType.filme:
        return isCompleted ? 'Assistido' : 'Não assistido';
      case MediaType.livro:
        return 'Página $currentPage / $totalPages';
      case MediaType.jogo:
        return isCompleted ? 'Completo' : 'Em progresso';
      case MediaType.podcast:
        return 'Episódio $currentEpisode / $totalEpisodes';
      case MediaType.webtoon:
        return 'Página $currentPage / $totalPages';
    }
  }

  String get typeName {
    switch (type) {
      case MediaType.serie:
        return 'Série';
      case MediaType.filme:
        return 'Filme';
      case MediaType.livro:
        return 'Livro';
      case MediaType.jogo:
        return 'Jogo';
      case MediaType.podcast:
        return 'Podcast';
      case MediaType.anime:
        return 'Anime';
      case MediaType.webtoon:
        return 'Webtoon';
    }
  }
}
