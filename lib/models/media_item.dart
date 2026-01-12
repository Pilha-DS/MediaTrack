import 'package:flutter/material.dart';
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

@HiveType(typeId: 2)
enum MediaStatus {
  @HiveField(0)
  naoIniciado,
  @HiveField(1)
  assistindo,
  @HiveField(2)
  lendo,
  @HiveField(3)
  pausado,
  @HiveField(4)
  concluido,
  @HiveField(5)
  reassistindo,
  @HiveField(6)
  emEspera,
  @HiveField(7)
  dropado,
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

  @HiveField(16)
  MediaStatus status;

  @HiveField(17)
  bool wasCompleted;

  @HiveField(18)
  MediaStatus? previousStatus;

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
    this.status = MediaStatus.naoIniciado,
    this.wasCompleted = false,
    this.previousStatus,
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

  String get statusName {
    switch (status) {
      case MediaStatus.naoIniciado:
        return 'Não Iniciado';
      case MediaStatus.assistindo:
        return 'Assistindo';
      case MediaStatus.lendo:
        return 'Lendo';
      case MediaStatus.pausado:
        return 'Pausado';
      case MediaStatus.concluido:
        return 'Concluído';
      case MediaStatus.reassistindo:
        return 'Reassistindo';
      case MediaStatus.emEspera:
        return 'Em Espera';
      case MediaStatus.dropado:
        return 'Dropado';
    }
  }

  Color get statusColor {
    switch (status) {
      case MediaStatus.naoIniciado:
        return Colors.grey;
      case MediaStatus.assistindo:
      case MediaStatus.lendo:
        return Colors.blue;
      case MediaStatus.pausado:
        return Colors.orange;
      case MediaStatus.concluido:
        return Colors.green;
      case MediaStatus.reassistindo:
        return Colors.purple;
      case MediaStatus.emEspera:
        return Colors.amber;
      case MediaStatus.dropado:
        return Colors.red;
    }
  }

  // Atualiza o status automaticamente baseado no progresso
  // Não atualiza se estiver em "dropado" ou "pausado"
  void updateStatusAutomatically() {
    // Não atualiza se estiver em dropado ou pausado
    if (status == MediaStatus.dropado || status == MediaStatus.pausado) {
      return;
    }

    // Determina o valor atual baseado no tipo
    int current = 0;
    int total = 0;
    
    switch (type) {
      case MediaType.serie:
      case MediaType.anime:
        current = currentSeason > 0 && currentEpisode > 0 
            ? (currentSeason - 1) * totalEpisodes + currentEpisode 
            : 0;
        total = totalSeasons * totalEpisodes;
        break;
      case MediaType.livro:
      case MediaType.webtoon:
        current = currentPage;
        total = totalPages;
        break;
      case MediaType.podcast:
        current = currentEpisode;
        total = totalEpisodes;
        break;
      case MediaType.filme:
      case MediaType.jogo:
        // Para filmes e jogos, usa isCompleted diretamente
        if (isCompleted) {
          status = MediaStatus.concluido;
          wasCompleted = true;
        } else {
          status = MediaStatus.naoIniciado;
        }
        return;
    }

    // Se current = 0, então não iniciado
    if (current == 0) {
      status = MediaStatus.naoIniciado;
      isCompleted = false;
      return;
    }

    // Se chegou ao final
    if (current >= total && total > 0) {
      // Se está marcado como completo, atualiza status e marca wasCompleted
      if (isCompleted) {
        status = MediaStatus.concluido;
        wasCompleted = true;
      }
      // Se não está completo mas chegou ao final, mantém o status atual
      // (o usuário pode usar o botão para marcar como concluído)
      return;
    }

    // Se current > 0 e não está completo
    if (wasCompleted) {
      // Se já foi concluído antes, então está reassistindo/relendo
      if (type == MediaType.livro || type == MediaType.webtoon) {
        status = MediaStatus.lendo; // Relendo
      } else {
        status = MediaStatus.reassistindo;
      }
    } else {
      // Primeira vez assistindo/lendo
      if (type == MediaType.livro || type == MediaType.webtoon) {
        status = MediaStatus.lendo;
      } else {
        status = MediaStatus.assistindo;
      }
    }
  }

  // Método para marcar como concluído/não concluído
  void toggleCompleted() {
    isCompleted = !isCompleted;
    if (isCompleted) {
      status = MediaStatus.concluido;
      wasCompleted = true;
    } else {
      // Se desmarcar como completo, atualiza o status automaticamente
      updateStatusAutomatically();
    }
  }

  // Método para pausar (salva o status anterior)
  void pause() {
    if (status == MediaStatus.pausado) return; // Já está pausado
    
    // Salva o status anterior (exceto se for dropado ou concluído)
    // Permite salvar mesmo se for naoIniciado, para poder restaurar depois
    if (status != MediaStatus.dropado && 
        status != MediaStatus.concluido) {
      previousStatus = status;
    } else {
      // Se está dropado ou concluído, não pode pausar
      return;
    }
    status = MediaStatus.pausado;
  }

  // Método para dropar (salva o status anterior)
  void drop() {
    if (status == MediaStatus.dropado) return; // Já está dropado
    
    // Salva o status anterior apenas se não for um status especial
    if (status != MediaStatus.concluido) {
      previousStatus = status;
    }
    status = MediaStatus.dropado;
  }

  // Método para despausar (restaura o status anterior)
  void unpause() {
    if (status != MediaStatus.pausado) return;
    
    // Se tem status anterior válido, restaura
    if (previousStatus != null && 
        previousStatus != MediaStatus.pausado && 
        previousStatus != MediaStatus.dropado &&
        previousStatus != MediaStatus.concluido) {
      status = previousStatus!;
      previousStatus = null;
      return;
    }
    
    // Se não tem status anterior válido, calcula baseado no progresso
    previousStatus = null;
    
    // Determina o valor atual baseado no tipo
    int current = 0;
    
    switch (type) {
      case MediaType.serie:
      case MediaType.anime:
        current = currentSeason > 0 && currentEpisode > 0 
            ? (currentSeason - 1) * totalEpisodes + currentEpisode 
            : 0;
        break;
      case MediaType.livro:
      case MediaType.webtoon:
        current = currentPage;
        break;
      case MediaType.podcast:
        current = currentEpisode;
        break;
      case MediaType.filme:
      case MediaType.jogo:
        status = isCompleted ? MediaStatus.concluido : MediaStatus.naoIniciado;
        return;
    }
    
    // Se current = 0, então não iniciado
    if (current == 0) {
      status = MediaStatus.naoIniciado;
      return;
    }
    
    // Se current > 0, determina se é primeira vez ou reassistindo/relendo
    if (wasCompleted) {
      // Se já foi concluído antes, então está reassistindo/relendo
      if (type == MediaType.livro || type == MediaType.webtoon) {
        status = MediaStatus.lendo;
      } else {
        status = MediaStatus.reassistindo;
      }
    } else {
      // Primeira vez assistindo/lendo
      if (type == MediaType.livro || type == MediaType.webtoon) {
        status = MediaStatus.lendo;
      } else {
        status = MediaStatus.assistindo;
      }
    }
  }

  // Método para desdropar (restaura o status anterior)
  void undrop() {
    if (status != MediaStatus.dropado) return;
    
    if (previousStatus != null && 
        previousStatus != MediaStatus.pausado && 
        previousStatus != MediaStatus.dropado &&
        previousStatus != MediaStatus.concluido) {
      status = previousStatus!;
      previousStatus = null;
    } else {
      // Se não tem status anterior válido, usa o automático
      previousStatus = null;
      updateStatusAutomatically();
    }
  }
}
